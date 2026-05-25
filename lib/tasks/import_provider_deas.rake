require "csv"

namespace :legacy do
  desc "Import legacy provider DEA records"
  task import_provider_deas: :environment do
    file = ENV.fetch("FILE")

    CSV.foreach(file, headers: true) do |row|
      ppi = ProviderPersonalInformation.find_by(encompass_id_text: row["PracID"])
      next unless ppi

      next if ppi.provider_attest_id.blank?
      next unless ProviderAttest.exists?(id: ppi.provider_attest_id)

      ProviderDea.find_or_create_by!(
        provider_attest_id: ppi.provider_attest_id,
        caqh_provider_attest_id: ppi.caqh_provider_attest_id,
        dea_number: row["DEARegisNum"]
      ) do |dea|
        dea.application_date = row["DEAIssueDate"]
        dea.expiration_date = row["DEAExpDate"]
        dea.full_schedule = row["DEAScheduleFull"]
        dea.dea_license_limitation_flag = row["DEALimitedOrNot"]
        dea.dea_license_limitation_explanation = row["DEALimitedExplanation"]
        dea.show_on_tickler = row["ShowOnTickler"]
      end
    end

    puts "DEA import completed"
  end
end