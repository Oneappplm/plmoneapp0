# app/services/webscraper/dea_service.rb
require 'nokogiri'
require 'open-uri'
require 'wicked_pdf'

class Webscraper::DeaService < WebscraperService
  def initialize(dea, reference_html)
    @dea = dea
    @reference_html = reference_html
  end

  def call
    html_path = Rails.root.join('public', @reference_html)
    html_content = File.read(html_path)
    doc = Nokogiri::HTML(html_content)

    insert_dea(doc)
    insert_user_data(doc)
    insert_master_data(doc)

    updated_html_path = Rails.root.join('tmp', 'updated_page.html')
    File.write(updated_html_path, doc.to_html)

    generate_pdf(doc.to_html)
  end

  private

  # Insert DEA number
  def insert_dea(doc)
    doc.at_css('input#dea_input_field')&.[]=('value', @dea)
    doc.at_css('#dea_value')&.content = @dea
  end

  # Insert Provider DEA + Profile Data
  def insert_user_data(doc)
    provider_dea = ProviderDea.find_by(dea_number: @dea)
    provider     = ProviderPersonalInformation.find_by(
      provider_attest_id: provider_dea&.provider_attest_id
    )

    doc.at_css('#provider_name')&.content =
      [provider&.last_name, provider&.first_name].compact.join(', ')

    doc.at_css('#provider_city')&.content = provider&.birth_city

    doc.at_css('#provider_dea_schedules')&.content =
      provider_dea&.schedules_held&.join(' ')

    doc.at_css('#dea_expiration_date')&.content =
      provider_dea&.expiration_date&.strftime('%m/%d/%Y')

    doc.at_css('#dea_source_date')&.content =
      Time.current.in_time_zone('Pacific Time (US & Canada)').strftime('%m/%d/%Y')
  end

  # Insert DEA MASTER RECORD Data
  def insert_master_data(doc)
    master = DeaMasterRecord.find_by(dea_number: @dea)
    provider_dea = ProviderDea.find_by(dea_number: @dea)

    # Resolve final state name ONCE
    final_state_name = resolve_state_name(master, provider_dea)

    doc.at_css('#provider_dea_state')&.content = final_state_name

    return unless master

    doc.at_css('#validationForm\\:busAct')&.content = master.business_activity.to_s
    doc.at_css('#validationForm\\:busAddr1')&.content = master.address1.to_s
    doc.at_css('#validationForm\\:busAddr2')&.content = master.address2.to_s

    doc.at_css('#validationForm\\:busAddr3')&.content =
      master.state_license_number.presence || master.address2.to_s

    doc.at_css('#provider_city')&.content = master.city.to_s
    doc.at_css('#validationForm\\:zip')&.content = master.zip.to_s
    doc.at_css('#provider_dea_schedules')&.content = master.schedules.to_s

    if master.expiration_date.present?
      doc.at_css('#dea_expiration_date')&.content =
        master.expiration_date.strftime('%m/%d/%Y')
    end
    doc.at_css('#fee_status')&.content = 'Exempt'
  end

  # Resolve State Name (IMPORTANT)
  def resolve_state_name(master, provider_dea)
    state_code =
      master&.state.presence ||
      provider_dea&.state.presence

    return nil if state_code.blank?

    State.find_by(alpha_code: state_code)&.name || state_code
  end

  # Convert HTML → PDF
  def generate_pdf(html_content)
    pdf_path = Rails.root.join('public', 'screenshots', 'dea_screenshot.pdf')
    FileUtils.mkdir_p(File.dirname(pdf_path))

    pdf = WickedPdf.new.pdf_from_string(html_content)
    File.open(pdf_path, 'wb') { |file| file.write(pdf) }

    pdf_path.to_s
  end
end
