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
    # 1. Load HTML from file
    html_path = Rails.root.join('public', @reference_html)
    html_content = File.read(html_path)
    doc = Nokogiri::HTML(html_content)

    # 2. Insert DEA number
    insert_dea(doc)

    # 3. Insert provider personal info (from provider tables)
    insert_user_data(doc)

    # 4. Insert DEA Master Record data (important!)
    insert_master_data(doc)

    # 5. Save modified HTML
    updated_html_path = Rails.root.join('tmp', 'updated_page.html')
    File.write(updated_html_path, doc.to_html)

    # 6. Convert final HTML → PDF
    pdf_path = generate_pdf(doc.to_html)

    return pdf_path
  end

  private

  #################################
  # Insert DEA number UI Fields
  #################################
  def insert_dea(doc)
    dea_input = doc.at_css('input#dea_input_field')
    dea_input['value'] = @dea if dea_input

    dea_element = doc.at_css('#dea_value')
    dea_element.content = @dea if dea_element && dea_element.name != 'input'
  end

  #################################
  # Insert Provider Name, State, Schedules (from provider profile)
  #################################
  def insert_user_data(doc)
    provider_dea = ProviderDea.find_by(dea_number: @dea)
    provider = ProviderPersonalInformation.find_by(provider_attest_id: provider_dea&.provider_attest_id)

    state_name = if provider_dea&.state.present?
                    State.find_by(id: provider_dea.state)&.name
                  else
                    nil
                  end

    doc.at_css('#provider_name')&.content = "#{provider&.last_name}, #{provider&.first_name}"
    doc.at_css('#provider_city')&.content = provider&.birth_city
    doc.at_css('#provider_dea_state')&.content = state_name
    doc.at_css('#provider_dea_schedules')&.content = provider_dea&.schedules_held&.join(" ")
    doc.at_css('#dea_expiration_date')&.content = provider_dea&.expiration_date&.strftime('%m/%d/%Y')
    doc.at_css('#dea_source_date')&.content = Time.now.in_time_zone('Pacific Time (US & Canada)').strftime("%m/%d/%Y")
  end

  #################################
  # ⭐ NEW — Insert data from DEA MASTER RECORD
  #################################
  def insert_master_data(doc)
    master = DeaMasterRecord.find_by(dea_number: @dea)
    return unless master

    # Business Activity
    doc.at_css('#validationForm\\:busAct')&.content = master.business_activity.to_s

    # Business Address 1
    doc.at_css('#validationForm\\:busAddr1')&.content = master.address1.to_s

    # Business Address 2
    doc.at_css('#validationForm\\:busAddr2')&.content = master.address2.to_s

    # Business Address 3
    doc.at_css('#validationForm\\:busAddr3')&.content =
      master.state_license_number.presence || master.address2.to_s

    # City
    doc.at_css('#provider_city')&.content = master.city.to_s

    # State
    doc.at_css('#provider_dea_state')&.content = master.state.to_s

    # Zip
    doc.at_css('#validationForm\\:zip')&.content = master.zip.to_s

    # Schedules
    doc.at_css('#provider_dea_schedules')&.content = master.schedules.to_s

    # Expiration Date
    doc.at_css('#dea_expiration_date')&.content =
      (master.expiration_date ? master.expiration_date.strftime("%m/%d/%Y") : "")

    # Fee status
    doc.at_css('#fee_status')&.content = "Exempt"
  end


  #################################
  # Convert updated HTML → PDF
  #################################
  def generate_pdf(html_content)
    pdf_path = Rails.root.join('public', "screenshots/dea_screenshot.pdf")
    FileUtils.mkdir_p(File.dirname(pdf_path))

    WickedPdf.new.pdf_from_string(html_content).tap do |pdf|
      File.open(pdf_path, 'wb') { |file| file.write(pdf) }
    end

    pdf_path.to_s
  end
end
