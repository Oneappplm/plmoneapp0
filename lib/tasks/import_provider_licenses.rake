require "csv"

namespace :legacy do
  desc "Import legacy provider license records"
  task import_provider_licenses: :environment do
    file = ENV.fetch("FILE")

    imported = 0
    skipped = 0

    CSV.foreach(file, headers: true) do |row|
      ppi = ProviderPersonalInformation.find_by(encompass_id_text: row["PracID"])

      unless ppi
        skipped += 1
        next
      end

      next if row["LicenseNumber"].blank?

      license = ProviderLicensure.find_or_initialize_by(
        provider_attest_id: ppi.provider_attest_id,
        caqh_provider_attest_id: ppi.caqh_provider_attest_id,
        license_number: row["LicenseNumber"]
      )

      license.license_issue_date = row["IssueDate"]
      license.license_expiration_date = row["ExpirationDate"]
      license.is_primary_license = row["PrimaryLicense"]
      license.state_id = row["State"]
      license.audit_status = row["Status"]
      license.license_comment = row["Comments"]

      license.save!(validate: false)
      imported += 1
    end

    puts "License import completed"
    puts "Imported/updated: #{imported}"
    puts "Skipped: #{skipped}"
  end
end