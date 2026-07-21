# frozen_string_literal: true

require "nokogiri"
require "open-uri"
require "wicked_pdf"
require "fileutils"
require "pathname"

class Webscraper::DeaService < WebscraperService
  FULL_SCHEDULES = %w[
    2
    2N
    3
    3N
    4
    5
  ].freeze

  def initialize(
    dea,
    reference_html,
    master_record: nil,
    provider_dea: nil,
    provider_info: nil
  )
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
      insert_uploaded_master_data(
        document,
        master,
        provider_dea,
        provider_info
      )
    else
      insert_manual_data(
        document,
        provider_dea,
        provider_info
      )
    end

    insert_source_date(document)

    updated_html_path =
      Rails.root.join("tmp", "updated_page.html")

    FileUtils.mkdir_p(updated_html_path.dirname)

    File.write(
      updated_html_path,
      document.to_html
    )

    generate_pdf(document.to_html)
  end

  private

  def reference_html_path
    path = Pathname.new(@reference_html.to_s)

    path.absolute? ?
      path :
      Rails.root.join("public", path)
  end

  def normalize_dea_number(value)
    value.to_s
         .upcase
         .gsub(/[^A-Z0-9]/, "")
  end

  def standard_dea_number(value)
    normalize_dea_number(value).first(9)
  end

  def insert_dea(document)
    displayed_dea_number =
      standard_dea_number(@dea)

    if displayed_dea_number.blank?
      displayed_dea_number =
        standard_dea_number(
          resolved_provider_dea&.dea_number
        )
    end

    document.at_css(
      "input#dea_input_field"
    )&.[]=(
      "value",
      displayed_dea_number
    )

    document.at_css("#dea_value")&.content =
      displayed_dea_number
  end

  # When a matching uploaded master record exists, all DEA
  # verification values come from that uploaded record.
  def insert_uploaded_master_data(
    document,
    master,
    provider_dea,
    provider_info
  )
    provider_name =
      master.name.presence ||
      provider_display_name(provider_info)

    document.at_css("#provider_name")&.content =
      provider_name.to_s

    document.at_css(
      "#validationForm\\:busAct"
    )&.content =
      master.business_activity.to_s

    document.at_css(
      "#validationForm\\:busAddr1"
    )&.content =
      master.address1.to_s

    document.at_css(
      "#validationForm\\:busAddr2"
    )&.content =
      master.address2.to_s

    document.at_css(
      "#validationForm\\:busAddr3"
    )&.content =
      master.state_license_number.to_s

    document.at_css("#provider_city")&.content =
      master.city.to_s

    document.at_css(
      "#validationForm\\:zip"
    )&.content =
      master.zip.to_s

    document.at_css(
      "#provider_dea_state"
    )&.content =
      state_name(master.state).to_s

    document.at_css(
      "#provider_dea_schedules"
    )&.content =
      normalize_schedules(
        master.schedules
      ).join(" ")

    document.at_css(
      "#dea_expiration_date"
    )&.content =
      format_date(master.expiration_date)

    document.at_css("#fee_status")&.content =
      "Exempt"

    # Keep ProviderDea synchronized with the uploaded result so
    # the Registration page displays the same information.
    synchronize_provider_dea!(
      provider_dea,
      master
    )
  end

  # When no matching uploaded record exists, retain and display the
  # manually entered ProviderDea values.
  def insert_manual_data(
    document,
    provider_dea,
    provider_info
  )
    document.at_css("#provider_name")&.content =
      provider_display_name(provider_info)

    document.at_css("#provider_city")&.content =
      provider_info&.birth_city.to_s

    document.at_css(
      "#provider_dea_state"
    )&.content =
      state_name(provider_dea&.state).to_s

    document.at_css(
      "#provider_dea_schedules"
    )&.content =
      Array(provider_dea&.schedules_held)
        .map(&:to_s)
        .reject(&:blank?)
        .join(" ")

    document.at_css(
      "#dea_expiration_date"
    )&.content =
      format_date(
        provider_dea&.expiration_date
      )

    document.at_css("#fee_status")&.content =
      ""
  end

  def insert_source_date(document)
    document.at_css("#dea_source_date")&.content =
      Time.current
          .in_time_zone(
            "Pacific Time (US & Canada)"
          )
          .strftime("%m/%d/%Y")
  end

  def synchronize_provider_dea!(
    provider_dea,
    master
  )
    return unless provider_dea.present?
    return unless master.present?

    schedules =
      normalize_schedules(master.schedules)

    provider_dea.update!(
      state: master.state,
      expiration_date: master.expiration_date,
      schedules_held: schedules,
      full_schedule:
        full_schedule?(schedules) ? "Yes" : "No"
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

    @master =
      DeaMasterRecord
        .matching_dea(normalized_dea)
        .order(
          Arel.sql(
            "CASE WHEN LENGTH(dea_number) = 9 THEN 0 ELSE 1 END"
          )
        )
        .first
  end

  def resolved_provider_dea
    return @provider_dea if @provider_dea.present?

    normalized_dea =
      standard_dea_number(@dea)

    return nil if normalized_dea.blank?

    @provider_dea =
      ProviderDea.where(
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

    @provider_info =
      ProviderPersonalInformation.find_by(
        provider_attest_id:
          provider_dea.provider_attest_id
      )
  end

  def provider_display_name(provider)
    return "" unless provider.present?

    [
      provider.last_name,
      provider.first_name
    ].reject(&:blank?).join(", ")
  end

  def normalize_schedules(value)
    Array(value)
      .flat_map do |item|
        item.to_s.split(/[,\s]+/)
      end
      .map(&:strip)
      .reject(&:blank?)
      .select do |schedule|
        FULL_SCHEDULES.include?(schedule)
      end
      .uniq
      .sort_by do |schedule|
        FULL_SCHEDULES.index(schedule)
      end
  end

  def full_schedule?(schedules)
    (FULL_SCHEDULES - schedules).empty?
  end

  def state_name(state_code)
    return nil if state_code.blank?

    State.find_by(
      alpha_code: state_code
    )&.name || state_code
  end

  def format_date(value)
    return "" if value.blank?

    value.to_date.strftime("%m/%d/%Y")
  rescue ArgumentError, NoMethodError
    value.to_s
  end

  def generate_pdf(html_content)
    pdf_path =
      Rails.root.join(
        "public",
        "screenshots",
        "dea_screenshot.pdf"
      )

    FileUtils.mkdir_p(pdf_path.dirname)
    FileUtils.rm_f(pdf_path)

    pdf =
      WickedPdf.new.pdf_from_string(
        html_content
      )

    File.open(pdf_path, "wb") do |file|
      file.write(pdf)
    end

    pdf_path.to_s
  end
end