require 'csv'

namespace :broward do
  desc 'Import Broward liability records'
  task import_liability: :environment do
    file = ENV.fetch('FILE')

    imported = 0
    updated = 0
    skipped = 0

    CSV.foreach(file, headers: true) do |row|
      begin
        encid = row['ENCID'].to_s.strip

        provider =
          ProviderPersonalInformation.find_by(
            encompass_id_text: encid,
            legacy_client_name: 'Broward Health'
          )

        unless provider
          skipped += 1
          puts "Provider not found: #{encid}"
          next
        end

        liability = ProviderInsuranceCoverage.find_or_initialize_by(
          provider_attest_id: provider.provider_attest_id,
          caqh_provider_insurance_id: row['tbl_XII_ID']
        )

        liability.assign_attributes(
          caqh_provider_attest_id: provider.caqh_provider_attest_id,
          insurance_carrier_name: row['CarrierName'],
          policy_holder: row['PolicyHolder'],
          policy_number: row['PolicyNumber'],
          original_start_date: row['OriginalEffectiveDate'],
          start_date: row['OriginalEffectiveDate'],
          end_date: row['ExpirationDate'],
          coverage_amount_occurrence: row['PeerClaimAmount'],
          coverage_amount_aggregate: row['AggregateAmount'],
          umbrella_coverage_amount: row['UmbrellaCoverageAmount'],
          self_insured_flag: row['SelfInsured'],
          show_on_tickler: row['ShowOnTickler'],
          prof_liability_does_not_expire: row['NotExpire'],
          form_type: 'main'
        )

        if liability.new_record?
          imported += 1
        else
          updated += 1
        end

        liability.save!(validate: false)

      rescue => e
        skipped += 1
        puts "ERROR #{encid}: #{e.message}"
      end
    end

    puts
    puts "Imported: #{imported}"
    puts "Updated : #{updated}"
    puts "Skipped : #{skipped}"
  end
end