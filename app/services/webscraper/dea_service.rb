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

    # 2. Insert DEA in the page
    insert_dea(doc)

    # 3. Fetch and insert database data
    insert_user_data(doc)

    # 4. Save modified HTML
    updated_html_path = Rails.root.join('tmp', 'updated_page.html')
    File.write(updated_html_path, doc.to_html)

    # 5. Convert HTML to PDF
    pdf_path = generate_pdf(doc.to_html)

    pdf_path # Return the path of the generated PDF
  end

  private

  def insert_dea(doc)
    # Handle input field
    dea_input = doc.at_css('input#dea_input_field')
    dea_input['value'] = @dea if dea_input

    # Handle normal content elements (div, span, p, etc.)
    dea_element = doc.at_css('#dea_value')
    dea_element.content = @dea if dea_element && dea_element.name != 'input'
  end

  def insert_user_data(doc)
    provider_dea = ProviderDea.find_by(dea_number: @dea)
    provider = ProviderPersonalInformation.find_by(provider_attest_id: provider_dea.provider_attest_id) if provider_dea

    doc.at_css('#provider_name')&.content = "#{provider&.last_name}, #{provider&.first_name}"
    doc.at_css('#provider_city')&.content = provider&.birth_city
    doc.at_css('#provider_dea_state')&.content = provider_dea&.state
    doc.at_css('#provider_dea_schedules')&.content = provider_dea&.schedules_held.join(" ")
    doc.at_css('#dea_expiration_date')&.content = provider_dea&.expiration_date&.strftime('%m/%d/%Y')
    doc.at_css('#dea_source_date')&.content = Date.today.strftime('%m/%d/%Y')
  end

  def generate_pdf(html_content)
    pdf_path = Rails.root.join('public', "screenshots/dea_screenshot.pdf")
    FileUtils.mkdir_p(File.dirname(pdf_path)) # Ensure directory exists

    WickedPdf.new.pdf_from_string(html_content).tap do |pdf|
      File.open(pdf_path, 'wb') { |file| file.write(pdf) }
    end

    pdf_path.to_s
  end
end
