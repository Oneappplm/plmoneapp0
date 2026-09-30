class Mhc::BcbsReportsController < ApplicationController
  def index
    @clients =
      ProviderPersonalInformation
        .where.not(legacy_client_name: [nil, ""])
        .distinct
        .order(:legacy_client_name)
        .pluck(:legacy_client_name)
  end

  def download
    client_name = params[:client_name].to_s.strip

    unless valid_client?(client_name)
      redirect_to(
        mhc_bcbs_reports_path,
        alert: "Please select a valid client."
      )
      return
    end

    package =
      Reports::BcbsDetailXlsxExporter.new(
        client_name: client_name
      ).call

    filename =
      "#{safe_client_name(client_name)}_BCBS_Detail_Report_#{Date.current.strftime('%Y%m%d')}.xlsx"

    send_data(
      package.to_stream.read,
      filename: filename,
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      disposition: "attachment"
    )
  rescue StandardError => e
    Rails.logger.error(
      "[BCBS REPORT] #{e.class}: #{e.message}"
    )

    Rails.logger.error(
      e.backtrace.first(20).join("\n")
    )

    redirect_to(
      mhc_bcbs_reports_path,
      alert: "Unable to generate BCBS Detail Report."
    )
  end

  private

  def valid_client?(client_name)
    return false if client_name.blank?

    ProviderPersonalInformation.exists?(
      legacy_client_name: client_name
    )
  end

  def safe_client_name(client_name)
    client_name.parameterize(
      separator: "_"
    )
  end
end
