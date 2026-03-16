require "csv"
require "fileutils"

module Reports
  class LicensureBulkCsvExporter
    HEADERS = [
      "PracID",
      "Npi",
      "Source Date",
      "LastName",
      "FirstName",
      "PractitionerType",
      "LicenseNumber",
      "LicenseState",
      "ExpirationDate",
      "LicenseStatus",
      "AdverseAction",
      "GeneratedAt"
    ].freeze

    def initialize(rows:)
      @rows = rows
    end

    def call
      reports_dir = Rails.root.join("tmp", "reports")
      FileUtils.mkdir_p(reports_dir)

      filename = "licensure_report_#{Time.current.to_i}.csv"
      path = reports_dir.join(filename)

      generated_at = Time.current.strftime("%m/%d/%Y")

      CSV.open(path, "wb", write_headers: true, headers: HEADERS) do |csv|
        @rows.each do |row|
          csv << HEADERS.map do |header|
            if header == "GeneratedAt"
              generated_at
            else
              row[header.to_sym]
            end
          end
        end
      end

      path.to_s
    end
  end
end
