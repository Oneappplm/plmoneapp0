class Mhc::ReportsController < ApplicationController
	def index
		
	end

	def generate_all_reports
    downloads = {}

    dea_rows = build_dea_rows
    if dea_rows.any?
      dea_csv_path = Reports::DeaBulkCsvExporter.new(rows: dea_rows).call
      downloads[:dea] = mhc_download_report_path(path: dea_csv_path, filename: File.basename(dea_csv_path))
    end

    licensure_rows = build_licensure_rows
    if licensure_rows.any?
      licensure_csv_path = Reports::LicensureBulkCsvExporter.new(rows: licensure_rows).call
      downloads[:licensure] = mhc_download_report_path(path: licensure_csv_path, filename: File.basename(licensure_csv_path))
    end

    if downloads.blank?
      return render json: {
        success: false,
        message: "No report data found."
      }, status: :unprocessable_entity
    end

    render json: {
      success: true,
      message: "Reports generated successfully.",
      downloads: downloads
    }, status: :ok
  rescue => e
    render json: {
      success: false,
      message: e.message
    }, status: :unprocessable_entity
  end

  def download_report
    path = params[:path].to_s
    filename = params[:filename].presence || File.basename(path)
    reports_dir = Rails.root.join("tmp", "reports").to_s

    unless path.present? && path.start_with?(reports_dir) && File.exist?(path)
      return head :not_found
    end

    send_file(
      path,
      type: "text/csv; charset=utf-8",
      disposition: "attachment",
      filename: filename
    )
  end

  private

  def build_dea_rows
    rows = []

    provider_deas = ProviderDea
                      .joins(:rva_informations)
                      .joins("INNER JOIN dea_webcrawler_logs ON dea_webcrawler_logs.rva_information_id = rva_informations.id")
                      .distinct

    provider_deas.each do |provider_dea|
      provider_info = ProviderPersonalInformation.find_by(
        provider_attest_id: provider_dea.provider_attest_id
      )
      next unless provider_info

      rva_info = provider_dea.latest_registration_rva_information(provider_info.id)
      next unless rva_info

      dea_webcrawler_log = provider_dea.latest_completed_dea_webcrawler_log(provider_info.id)
      next unless dea_webcrawler_log

      rows << Reports::ExistingDeaReportDataBuilder.new(
        provider_info: provider_info,
        provider_dea: provider_dea,
        rva_info: rva_info,
        dea_webcrawler_log: dea_webcrawler_log
      ).call
    end

    rows
  end

  def build_licensure_rows
    rows = []

    provider_licensures = ProviderLicensure
                            .joins(:rva_informations)
                            .where(rva_informations: { audit_status: true })
                            .distinct

    provider_licensures.each do |provider_licensure|
      provider_info = ProviderPersonalInformation.find_by(
        provider_attest_id: provider_licensure.provider_attest_id
      )
      next unless provider_info

      rva_info = provider_licensure.rva_informations
                                   .order(created_at: :desc)
                                   .first
      next unless rva_info

      rows << Reports::ExistingLicensureReportDataBuilder.new(
        provider_info: provider_info,
        provider_licensure: provider_licensure,
        rva_info: rva_info
      ).call
    end

    rows
  end
end