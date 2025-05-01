require 'csv'

class HippocratesController < ApplicationController
  def index
  end

  def query
    result = Hippocrates::QueryService.new(params[:prompt]).call
    respond_to do |format|
      format.js { render locals: { result: result } }
    end
  end

  def expired_licenses
    if params[:prompt] == "Show me expired licenses"
      @results = ProviderLicense
        .joins(:provider)
        .where("provider_licenses.license_expiration_date < ?", Date.today)
        .where(providers: { api_token: nil })
    end

    respond_to do |format|
      format.js
      format.html
    end
  end

  def download_expired_license
    license_number = params[:license]
    format = params[:format]

    license = ProviderLicense.find_by(license_number: license_number)

    if format == "pdf"
      pdf_data = generate_table_pdf([license])
      send_data pdf_data, filename: "license_#{license_number}.pdf", type: "application/pdf"
    elsif format == "csv"
      csv_data = generate_csv(license)
      send_data csv_data, filename: "license_#{license_number}.csv"
    else
      redirect_to root_path, alert: "Invalid format"
    end
  end


  private

  def generate_csv(license)
    CSV.generate(headers: true) do |csv|
      csv << ["License Number", "Effective Date", "Expiration Date", "Renewal Date", "License Type", "No State License", "State ID"]

      csv << [
        license.license_number,
        license.license_effective_date,
        license.license_expiration_date,
        license.license_state_renewal_date,
        license.license_type,
        license.no_state_license,
        license.state_id
      ]
    end
  end

  def generate_table_pdf(licenses)
    Prawn::Document.new do |pdf|
      pdf.text "Expired Licenses Report", size: 18, style: :bold, align: :center
      pdf.move_down 20

      # Define table headers
      table_data = [
        ["License Number", "Effective Date", "Expiration Date", "Renewal Date", "License Type", "No State License", "State ID"]
      ]

      # Add each license row
      licenses.each do |license|
        table_data << [
          license.license_number,
          license.license_effective_date&.strftime("%b %d, %Y"),
          license.license_expiration_date&.strftime("%b %d, %Y"),
          license.license_state_renewal_date,
          license.license_type,
          license.no_state_license,
          license.state_id
        ]
      end

      pdf.table(table_data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = 'DDDDDD'
        self.row_colors = ["F9F9F9", "FFFFFF"]
      end
    end.render
  end

end
