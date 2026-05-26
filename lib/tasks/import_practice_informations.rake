require "csv"

namespace :legacy do
  desc "Import legacy practice information records"
  task import_practice_informations: :environment do
    file = ENV.fetch("FILE")

    imported = 0
    skipped = 0

    CSV.foreach(file, headers: true) do |row|
      ppi = ProviderPersonalInformation.find_by(encompass_id_text: row["PracID"])

      unless ppi
        skipped += 1
        next
      end

      next if row["PracticeOfficeName"].blank?

      practice = PracticeInformation.find_or_initialize_by(
        provider_attest_id: ppi.provider_attest_id,
        caqh_provider_attest_id: ppi.caqh_provider_attest_id,
        practice_name: row["PracticeOfficeName"],
        address: row["OfficeAddress"]
      )

      practice.address2 = row["OfficeSuite"]
      practice.additional_address = row["OfficeAdditionalAddress"]
      practice.city = row["OfficeCity"]
      practice.state = row["OfficeState"]
      practice.zip = row["OfficeZip"]
      practice.county = row["OfficeCounty"]
      practice.phone_number = row["OfficePhone"]
      practice.fax_number = row["OfficeFax"]
      practice.is_primary_location = row["PrimaryOffice"]
      practice.federal_tax_id = row["FedTaxID"]
      practice.name_affiliated_with_tax_id = row["FedTaxIDName"]

      practice.save!(validate: false)
      imported += 1
    end

    puts "Practice information import completed"
    puts "Imported/updated: #{imported}"
    puts "Skipped: #{skipped}"
  end
end