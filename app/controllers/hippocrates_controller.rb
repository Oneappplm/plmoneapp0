require 'csv'

class HippocratesController < ApplicationController
  before_action :set_license, only: :download_expired_license

  def index; end

  def query
    result = Hippocrates::QueryService.new(params[:prompt]).call

    respond_to do |format|
      format.js { render locals: { result: result } }
    end
  end

  def expired_licenses
    @results = fetch_expired_licenses if expired_license_prompt?

    respond_to do |format|
      format.js
      format.html
    end
  end

  def download_expired_license
    return redirect_to root_path, alert: "License not found" unless @license

    case params[:format]
    when "pdf"
      send_pdf([@license], "license_#{@license.license_number}.pdf")
    when "csv"
      send_csv(generate_csv(@license), "license_#{@license.license_number}.csv")
    else
      redirect_to root_path, alert: "Invalid format"
    end
  end

  def bulk_download_expired_licenses
    license_numbers = Array(params[:licenses])
    licenses = ProviderLicense.where(license_number: license_numbers)

    if licenses.blank?
      redirect_to root_path, alert: "No licenses found"
      return
    end

    case params[:format]
    when "pdf"
      send_pdf(licenses, "bulk_licenses.pdf")
    when "csv"
      send_csv(generate_bulk_csv(licenses), "bulk_licenses.csv")
    else
      redirect_to root_path, alert: "Invalid format"
    end
  end

  private

  # ========== Filters ==========

  def set_license
    @license = ProviderLicense.find_by(license_number: params[:license])
  end

  # ========== Helpers ==========

  def expired_license_prompt?
    params[:prompt].to_s.strip.casecmp("show me expired licenses").zero?
  end

  def fetch_expired_licenses
    ProviderLicense
      .joins(:provider)
      .where("provider_licenses.license_expiration_date <= ?", Date.today)
      .where(providers: { api_token: nil })
  end

  def send_pdf(licenses, filename)
    pdf_data = generate_table_pdf(licenses)
    send_data pdf_data, filename: filename, type: "application/pdf"
  end

  def send_csv(csv_data, filename)
    send_data csv_data, filename: filename
  end

  # ========== CSV Generation ==========

  def csv_headers
    ["License Number", "Effective Date", "Expiration Date", "Renewal Date", "License Type", "No State License", "State ID"]
  end

  def generate_csv(license)
    CSV.generate(headers: true) do |csv|
      csv << csv_headers
      csv << csv_row(license)
    end
  end

  def generate_bulk_csv(licenses)
    CSV.generate(headers: true) do |csv|
      csv << csv_headers
      licenses.each { |license| csv << csv_row(license) }
    end
  end

  def csv_row(license)
    [
      license.license_number,
      license.license_effective_date,
      license.license_expiration_date,
      license.license_state_renewal_date,
      license.license_type,
      license.no_state_license,
      license.state_id
    ]
  end

  # ========== PDF Generation ==========

  def generate_table_pdf(licenses)
    Prawn::Document.new do |pdf|
      pdf.text "Expired Licenses Report", size: 18, style: :bold, align: :center
      pdf.move_down 20

      table_data = [csv_headers]
      licenses.each { |license| table_data << formatted_pdf_row(license) }

      pdf.table(table_data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = 'DDDDDD'
        self.row_colors = ["F9F9F9", "FFFFFF"]
      end
    end.render
  end

  def formatted_pdf_row(license)
    [
      license.license_number,
      format_date(license.license_effective_date),
      format_date(license.license_expiration_date),
      license.license_state_renewal_date,
      license.license_type,
      license.no_state_license,
      license.state_id
    ]
  end

  def format_date(date)
    date&.strftime("%b %d, %Y")
  end
end

