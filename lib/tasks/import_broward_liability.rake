require 'csv'

namespace :broward do
  desc 'Import Broward liability records'
  task import_liability: :environment do
    file = ENV.fetch('FILE')
    provider_file = ENV.fetch('PROVIDER_FILE', '/tmp/broward_health_providers_253_export.csv')

    guid_to_encid = {}

    CSV.foreach(provider_file, headers: true) do |row|
      guid = row['PractitionerGUID'].to_s.strip.downcase
      encid = row['ENCID'].to_s.strip
      guid_to_encid[guid] = encid if guid.present? && encid.present?
    end

    imported = 0
    updated = 0
    skipped = 0

    CSV.foreach(file, headers: true) do |row|
      begin
        guid = row['PractitionerGUID'].to_s.strip.downcase
        encid = guid_to_encid[guid]

        provider = ProviderPersonalInformation.find_by(
          encompass_id_text: encid,
          legacy_client_name: 'Broward Health'
        )

        unless provider
          skipped += 1
          puts "Provider not found: GUID=#{guid}, ENCID=#{encid}"
          next
        end

        liability = ProviderInsuranceCoverage.find_or_initialize_by(
          provider_attest_id: provider.provider_attest_id,
          caqh_provider_insurance_id: row['tbl_XII_ID']
        )

        liability.assign_attributes(
          caqh_provider_attest_id: provider.caqh_provider_attest_id,
          insurance_carrier_name: row['InsuranceCarrierName'],
          address: row['Address'],
          address2: row['Address2'],
          city: row['City'],
          state: row['State'],
          postal_code: row['Zip'],
          phone_number: row['Phone'],
          fax_number: row['FAX'],
          email_address: row['Email'],
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
          claims_history_audit: row['ClaimsHistoryQualityAuditComplete'],
          audit_status: row['LiabCoverageQualityAuditComplete'].to_s == '1' ? 'Quality Audited' : nil,
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
        puts "ERROR GUID=#{row['PractitionerGUID']}: #{e.message}"
      end
    end

    puts
    puts "Imported: #{imported}"
    puts "Updated : #{updated}"
    puts "Skipped : #{skipped}"
  end
end