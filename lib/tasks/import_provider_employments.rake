require "csv"

namespace :legacy do
  desc "Import legacy provider employment records"
  task import_provider_employments: :environment do
    file = ENV.fetch("FILE")

    imported = 0
    skipped = 0

    CSV.foreach(file, headers: true) do |row|
      ppi = ProviderPersonalInformation.find_by(encompass_id_text: row["PracID"])

      unless ppi
        skipped += 1
        next
      end

      next if row["PracticeName"].blank?

      employment = ProviderEmployment.find_or_initialize_by(
        provider_attest_id: ppi.provider_attest_id,
        employer_name: row["PracticeName"],
        from_date: row["AttendedFrom"]
      )

      employment.address = row["Address"]
      employment.additional_address = row["Suite"]
      employment.city = row["City"]
      employment.state = row["State"]
      employment.zip = row["Zip"]
      employment.to_date = row["AttendedTo"]
      employment.position = row["Position"]
      employment.title = row["Position"]
      employment.comments = row["Comments"]
      employment.audit_status = row["VerifiedStatus"]
      employment.present = row["DateTo"].to_s.downcase.include?("present")

      employment.save!(validate: false)
      imported += 1
    end

    puts "Employment import completed"
    puts "Imported/updated: #{imported}"
    puts "Skipped: #{skipped}"
  end
end