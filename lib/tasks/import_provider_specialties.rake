require "csv"

namespace :legacy do
  desc "Import legacy provider specialty records"
  task import_provider_specialties: :environment do
    file = ENV.fetch("FILE")

    imported = 0
    skipped = 0

    CSV.foreach(file, headers: true) do |row|
      ppi = ProviderPersonalInformation.find_by(encompass_id_text: row["PracID"])

      unless ppi
        skipped += 1
        next
      end

      next if row["SpecialtyName"].blank?

      specialty = ProviderSpecialty.find_or_initialize_by(
        provider_attest_id: ppi.provider_attest_id,
        caqh_provider_attest_id: ppi.caqh_provider_attest_id,
        specialty_specialty_name: row["SpecialtyName"]
      )

      specialty.sub_specialty_specialty_name = row["Taxonomycode"]
      specialty.specialty_percent = row["RankingOrder"]
      specialty.board_certified = row["BoardCertStatus"]
      specialty.board_certified_flag = row["BoardCertStatus"].to_s.downcase == "yes"

      specialty.save!(validate: false)
      imported += 1
    end

    puts "Specialty import completed"
    puts "Imported/updated: #{imported}"
    puts "Skipped: #{skipped}"
  end
end