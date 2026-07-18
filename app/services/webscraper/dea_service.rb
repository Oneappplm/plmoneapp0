# app/services/webscraper/dea_service.rb

require "nokogiri"
require "open-uri"
require "wicked_pdf"

class Webscraper::DeaService < WebscraperService
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
    doc = Nokogiri::HTML(html_content)

    insert_dea(doc)
    insert_user_data(doc)
    insert_master_data(doc)

    updated_html_path = Rails.root.join("tmp", "updated_page.html")
    FileUtils.mkdir_p(updated_html_path.dirname)
    File.write(updated_html_path, doc.to_html)

    generate_pdf(doc.to_html)
  end

  private

  def reference_html_path
    path = Pathname.new(@reference_html.to_s)

    path.absolute? ? path : Rails.root.join("public", path)
  end

  def normalize_dea_number(value)
    value.to_s.upcase.gsub(/[^A-Z0-9]/, "")
  end

  # Insert the 10-character master DEA identifier.
  def insert_dea(doc)
    doc.at_css("input#dea_input_field")&.[]=(
      "value",
      @master&.dea_number.presence || @dea
    )

    doc.at_css("#dea_value")&.content =
      @master&.dea_number.presence || @dea
  end

  # Insert provider-facing data.
  def insert_user_data(doc)
    provider_dea = resolved_provider_dea
    provider = resolved_provider_info(provider_dea)

    provider_name =
      if provider.present?
        [provider.last_name, provider.first_name]
          .reject(&:blank?)
          .join(", ")
      else
        @master&.name.to_s
      end

    doc.at_css("#provider_name")&.content = provider_name

    doc.at_css("#provider_city")&.content =
      provider&.birth_city.to_s

    doc.at_css("#provider_dea_schedules")&.content =
      Array(provider_dea&.schedules_held)
        .reject(&:blank?)
        .join(" ")

    doc.at_css("#dea_expiration_date")&.content =
      provider_dea&.expiration_date&.strftime("%m/%d/%Y").to_s

    doc.at_css("#dea_source_date")&.content =
      Time.current
          .in_time_zone("Pacific Time (US & Canada)")
          .strftime("%m/%d/%Y")
  end

  # Insert DEA master record data.
  def insert_master_data(doc)
    master = resolved_master
    provider_dea = resolved_provider_dea

    doc.at_css("#provider_dea_state")&.content =
      resolve_state_name(master, provider_dea).to_s

    return unless master

    doc.at_css("#validationForm\\:busAct")&.content =
      master.business_activity.to_s

    doc.at_css("#validationForm\\:busAddr1")&.content =
      master.address1.to_s

    doc.at_css("#validationForm\\:busAddr2")&.content =
      master.address2.to_s

    doc.at_css("#validationForm\\:busAddr3")&.content =
      master.state_license_number.to_s

    doc.at_css("#provider_city")&.content =
      master.city.to_s

    doc.at_css("#validationForm\\:zip")&.content =
      master.zip.to_s

    final_schedules =
      Array(provider_dea&.schedules_held)
        .reject(&:blank?)
        .presence ||
      master.schedules.to_s
            .split(",")
            .map(&:strip)
            .reject(&:blank?)

    doc.at_css("#provider_dea_schedules")&.content =
      Array(final_schedules).join(" ")

    final_expiration_date =
      provider_dea&.expiration_date.presence ||
      master.expiration_date

    doc.at_css("#dea_expiration_date")&.content =
      final_expiration_date&.strftime("%m/%d/%Y").to_s

    doc.at_css("#fee_status")&.content = "Exempt"
  end

  def resolved_master
    return @master if @master.present?

    exact = DeaMasterRecord.find_by(dea_number: @dea)
    return @master = exact if exact.present?

    base_dea = @dea.first(9)

    @master = DeaMasterRecord.where(
      "dea_number LIKE ?",
      "#{ActiveRecord::Base.sanitize_sql_like(base_dea)}_"
    ).first
  end

  def resolved_provider_dea
    return @provider_dea if @provider_dea.present?

    exact = ProviderDea.find_by(dea_number: @dea)
    return @provider_dea = exact if exact.present?

    @provider_dea = ProviderDea.find_by(
      dea_number: @dea.first(9)
    )
  end

  def resolved_provider_info(provider_dea)
    return @provider_info if @provider_info.present?
    return nil if provider_dea.blank?

    ProviderPersonalInformation.find_by(
      provider_attest_id: provider_dea.provider_attest_id
    )
  end

  def resolve_state_name(master, provider_dea)
    state_code =
      provider_dea&.state.presence ||
      master&.state.presence

    return nil if state_code.blank?

    State.find_by(alpha_code: state_code)&.name || state_code
  end

  def generate_pdf(html_content)
    pdf_path =
      Rails.root.join(
        "public",
        "screenshots",
        "dea_screenshot.pdf"
      )

    FileUtils.mkdir_p(pdf_path.dirname)

    pdf = WickedPdf.new.pdf_from_string(html_content)

    File.open(pdf_path, "wb") do |file|
      file.write(pdf)
    end

    pdf_path.to_s
  end
end