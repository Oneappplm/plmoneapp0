# frozen_string_literal: true

require "prawn"
require "combine_pdf"
require "uri"
require "nokogiri"
require "open-uri"
require "wicked_pdf"
require "fileutils"
require "pathname"

class Webscraper::DeaService < WebscraperService
  FULL_SCHEDULES = %w[2 2N 3 3N 4 5].freeze

  def initialize(dea, reference_html, master_record: nil, provider_dea: nil, provider_info: nil)
    @dea = normalize_dea_number(dea)
    @reference_html = reference_html
    @master = master_record
    @provider_dea = provider_dea
    @provider_info = provider_info
  end

  def call
    html_content = File.read(reference_html_path)
    document = Nokogiri::HTML(html_content)

    master = resolved_master
    provider_dea = resolved_provider_dea
    provider_info = resolved_provider_info(provider_dea)

    Rails.logger.info(
      "[DEA CRAWLER] " \
      "dea=#{standard_dea_number(@dea)} " \
      "source=#{master.present? ? 'uploaded_file' : 'manual'} " \
      "master_id=#{master&.id.inspect} " \
      "provider_dea_id=#{provider_dea&.id.inspect} " \
      "master_expiration=#{master&.expiration_date.inspect} " \
      "manual_expiration=#{provider_dea&.expiration_date.inspect}"
    )

    insert_dea(document)

    if master.present?
      insert_uploaded_master_data(document, master, provider_dea, provider_info)
    else
      insert_manual_data(document, provider_dea, provider_info)
    end

    insert_source_date(document)

    html_content = document.to_html
    html_content
  end

  private

  def reference_html_path
    path = Pathname.new(@reference_html.to_s)
    path.absolute? ? path : Rails.root.join("public", path)
  end

  def normalize_dea_number(value)
    value.to_s.upcase.gsub(/[^A-Z0-9]/, "")
  end

  def standard_dea_number(value)
    normalize_dea_number(value).first(9)
  end

  def insert_dea(document)
    displayed_dea_number = standard_dea_number(@dea)

    if displayed_dea_number.blank?
      displayed_dea_number = standard_dea_number(resolved_provider_dea&.dea_number)
    end

    document.at_css("input#dea_input_field")&.[]=("value", displayed_dea_number)
    document.at_css("#dea_value")&.content = displayed_dea_number
  end

  # When a matching uploaded master record exists, all DEA
  # verification values come from that uploaded record.
  def insert_uploaded_master_data(document, master, provider_dea, provider_info)
    provider_name = master.name.presence || provider_display_name(provider_info)

    document.at_css("#provider_name")&.content = provider_name.to_s
    document.at_css("#validationForm\\:busAct")&.content = master.business_activity.to_s
    document.at_css("#validationForm\\:busAddr1")&.content = master.address1.to_s
    document.at_css("#validationForm\\:busAddr2")&.content = master.address2.to_s
    document.at_css("#validationForm\\:busAddr3")&.content = master.state_license_number.to_s
    document.at_css("#provider_city")&.content = master.city.to_s
    document.at_css("#validationForm\\:zip")&.content = master.zip.to_s
    document.at_css("#provider_dea_state")&.content = state_name(master.state).to_s

    document.at_css("#provider_dea_schedules")&.content =
      normalize_schedules(master.schedules).join(" ")

    document.at_css("#dea_expiration_date")&.content = format_date(master.expiration_date)
    document.at_css("#fee_status")&.content = "Exempt"

    # Keep ProviderDea synchronized with the uploaded result so
    # the Registration page displays the same information.
    synchronize_provider_dea!(provider_dea, master)
  end

  # When no matching uploaded record exists, retain and display the
  # manually entered ProviderDea values.
  def insert_manual_data(document, provider_dea, provider_info)
    document.at_css("#provider_name")&.content = provider_display_name(provider_info)
    document.at_css("#provider_city")&.content = provider_info&.birth_city.to_s
    document.at_css("#provider_dea_state")&.content = state_name(provider_dea&.state).to_s

    document.at_css("#provider_dea_schedules")&.content =
      Array(provider_dea&.schedules_held).map(&:to_s).reject(&:blank?).join(" ")

    document.at_css("#dea_expiration_date")&.content = format_date(provider_dea&.expiration_date)
    document.at_css("#fee_status")&.content = ""
  end

  def insert_source_date(document)
    document.at_css("#dea_source_date")&.content =
      Time.current.in_time_zone("Pacific Time (US & Canada)").strftime("%m/%d/%Y")
  end

  def synchronize_provider_dea!(provider_dea, master)
    return unless provider_dea.present?
    return unless master.present?

    schedules = normalize_schedules(master.schedules)

    provider_dea.update!(
      state: master.state,
      expiration_date: master.expiration_date,
      schedules_held: schedules,
      full_schedule: full_schedule?(schedules) ? "Yes" : "No"
    )
  rescue StandardError => e
    Rails.logger.error(
      "[DEA CRAWLER] ProviderDea synchronization failed " \
      "provider_dea_id=#{provider_dea.id} " \
      "master_record_id=#{master.id} " \
      "error=#{e.class}: #{e.message}"
    )
  end

  def resolved_master
    return @master if @master.present?

    normalized_dea = standard_dea_number(@dea)
    return nil if normalized_dea.blank?

    @master = DeaMasterRecord.matching_dea(normalized_dea)
                              .order(Arel.sql("CASE WHEN LENGTH(dea_number) = 9 THEN 0 ELSE 1 END"))
                              .first
  end

  def resolved_provider_dea
    return @provider_dea if @provider_dea.present?

    normalized_dea = standard_dea_number(@dea)
    return nil if normalized_dea.blank?

    @provider_dea = ProviderDea.where(
      <<~SQL.squish,
        LEFT(
          UPPER(
            REGEXP_REPLACE(
              COALESCE(dea_number, ''),
              '[^A-Za-z0-9]',
              '',
              'g'
            )
          ),
          9
        ) = ?
      SQL
      normalized_dea
    ).first
  end

  def resolved_provider_info(provider_dea)
    return @provider_info if @provider_info.present?
    return nil if provider_dea.blank?

    @provider_info = ProviderPersonalInformation.find_by(provider_attest_id: provider_dea.provider_attest_id)
  end

  def provider_display_name(provider)
    return "" unless provider.present?

    [provider.last_name, provider.first_name].reject(&:blank?).join(", ")
  end

  def normalize_schedules(value)
    Array(value)
      .flat_map { |item| item.to_s.split(/[,\s]+/) }
      .map(&:strip)
      .reject(&:blank?)
      .select { |schedule| FULL_SCHEDULES.include?(schedule) }
      .uniq
      .sort_by { |schedule| FULL_SCHEDULES.index(schedule) }
  end

  def full_schedule?(schedules)
    (FULL_SCHEDULES - schedules).empty?
  end

  def state_name(state_code)
    return nil if state_code.blank?

    State.find_by(alpha_code: state_code)&.name || state_code
  end

  def format_date(value)
    return "" if value.blank?

    value.to_date.strftime("%m/%d/%Y")
  rescue ArgumentError, NoMethodError
    value.to_s
  end

  public

  def generate_pdf(html_content, source_url:)
    pdf_path = Rails.root.join("tmp", "DEA_#{SecureRandom.hex(8)}.pdf")

    pacific_time = Time.current.in_time_zone("America/Los_Angeles")
    date_stamp = pacific_time.strftime("%-m/%-d/%y, %-I:%M %p")
    uri = URI.parse(source_url)

    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      raise ArgumentError, "Invalid DEA source URL"
    end

    # Remove old HTML-based URL if present.
    document = Nokogiri::HTML(html_content)
    document.css("#dea_pdf_source_link").remove

    # Generate PDF with the original DEA content.
    pdf_binary = WickedPdf.new.pdf_from_string(
      document.to_html,
      page_size: "Letter",
      margin: {
        top: 20,
        bottom: 25,
        left: 10,
        right: 10
      },
      header: {
        left: date_stamp,
        right: "CSA Registration Online Mgmt Tools",
        font_size: 8,
        spacing: 5
      },
      footer: {
        right: "[page]/[topage]",
        font_size: 8,
        spacing: 5
      },
      enable_local_file_access: true
    )

    original_pdf = CombinePDF.parse(pdf_binary)
    total_pages = original_pdf.pages.length

    raise "Generated DEA PDF has no pages" if total_pages.zero?

    original_pdf.pages.each do |page|
      media_box = page[:MediaBox]
      page_width = media_box[2].to_f - media_box[0].to_f
      page_height = media_box[3].to_f - media_box[1].to_f

      # Overlay using the same page dimensions.
      overlay = Prawn::Document.new(page_size: [page_width, page_height], margin: 0)

      # Prawn uses bottom-left PDF coordinates.
      # Position URL near the bottom, aligned with page numbering.
      overlay.fill_color "0000EE"

      overlay.text_box(
        source_url,
        at: [28, 20],
        width: page_width - 115,
        height: 12,
        size: 7,
        overflow: :shrink_to_fit,
        single_line: true,
        style: :underline,
        link: source_url
      )

      page << CombinePDF.parse(overlay.render).pages.first
    end

    File.binwrite(pdf_path, original_pdf.to_pdf)
    pdf_path.to_s
  end
end
