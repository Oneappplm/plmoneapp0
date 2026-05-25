require "csv"

namespace :legacy do
  desc "Import legacy provider DEA records"
  task import_provider_deas: :environment do
    file = ENV.fetch("FILE")

    imported = 0
    skipped = 0

    CSV.foreach(file, headers: true) do |row|
      ppi = ProviderPersonalInformation.find_by(encompass_id_text: row["PracID"])
      unless ppi
        skipped += 1
        next
      end

      next if row["DEARegisNum"].blank?

      dea = ProviderDea.find_or_initialize_by(
        provider_attest_id: ppi.provider_attest_id,
        caqh_provider_attest_id: ppi.caqh_provider_attest_id,
        dea_number: row["DEARegisNum"]
      )

      dea.application_date = row["DEAIssueDate"]
      dea.expiration_date = row["DEAExpDate"]
      dea.full_schedule = row["DEAScheduleFull"]
      dea.dea_license_limitation_flag = row["DEALimitedOrNot"]
      dea.dea_license_limitation_explanation = row["DEALimitedExplanation"]
      dea.show_on_tickler = row["ShowOnTickler"]

      dea.save!(validate: false)
      imported += 1
    end

    puts "DEA import completed"
    puts "Imported/updated: #{imported}"
    puts "Skipped: #{skipped}"
  end
end