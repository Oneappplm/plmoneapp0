require "csv"

namespace :legacy do
  desc "Import Broward Health providers from AppTracker export"
  task import_broward_health_providers: :environment do
    file = ENV.fetch("FILE")

    imported = 0
    updated = 0
    skipped = 0

    CSV.foreach(file, headers: true) do |row|
      encid = row["ENCID"].to_s.strip
      next if encid.blank?

      caqh_id = encid.gsub(/\D/, "").to_i

      ppi = ProviderPersonalInformation.find_or_initialize_by(
        encompass_id_text: encid
      )

      ppi.first_name = row["FirstName"]
      ppi.middle_name = row["MiddleName"]
      ppi.last_name = row["LastName"]
      ppi.caqh_provider_attest_id = caqh_id
      ppi.npi = row["NPI"]
      ppi.birth_date = row["BirthDate"]
      ppi.ssn = row["SSN"]
      ppi.provider_type_provider_type_abbreviation = row["PractitionerType"] if ppi.respond_to?(:provider_type_provider_type_abbreviation=)
      ppi.legacy_client_name = "Broward Health"

      if ppi.new_record?
        ppi.provider_attest ||= ProviderAttest.create!
        imported += 1
      else
        updated += 1
      end

      ppi.save!(validate: false)
    rescue => e
      skipped += 1
      puts "Skipped #{row['ENCID']}: #{e.message}"
    end

    puts "Broward Health provider import completed"
    puts "Imported: #{imported}"
    puts "Updated: #{updated}"
    puts "Skipped: #{skipped}"
  end
end