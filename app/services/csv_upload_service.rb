class CsvUploadService
  require 'csv'

  def initialize(order, csv_file)
    @order = order
    @csv_file = csv_file
  end

  def call
    CSV.foreach(@csv_file.path, headers: true) do |row|
      @order.provider_profiles.create!(
        first_name: row['First Name'],
        last_name: row['Last Name'],
        npi_number: row['NPI Number'],
        license_number: row['License Number'],
        state: row['State'],
        status: 'pending'
      )
    end
  end
end
