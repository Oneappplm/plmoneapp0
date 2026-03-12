require "csv"
require "fileutils"

module Reports
  class DeaBulkCsvExporter
    HEADERS = [
      "PractID",
      "NPI",
      "Lastname",
      "FirstName",
      "PractitionerType",
      "State",
      "DeaNumber",
      "ExpirationDate",
      "VerificationStatus",
      "DrugSchedule",
      "SourceDate"
    ].freeze

    def initialize(rows:)
      @rows = rows
    end

    def call
      reports_dir = Rails.root.join("tmp", "reports")
      FileUtils.mkdir_p(reports_dir)

      filename = "dea_monitoring_#{Time.current.to_i}.csv"
      path = reports_dir.join(filename)

      CSV.open(path, "wb", write_headers: true, headers: HEADERS) do |csv|
        @rows.each do |row|
          csv << HEADERS.map { |header| row[header.to_sym].to_s }
        end
      end

      path.to_s
    end
  end
end
