require 'csv'

namespace :broward do
  desc 'Import Broward licensure records'
  task import_licensure: :environment do
    file = ENV.fetch('FILE')
    provider_file = ENV.fetch('PROVIDER_FILE', '/tmp/broward_health_providers_253_export.csv')

    guid_to_encid = {}

    CSV.foreach(provider_file, headers: true) do |row|
      guid = row['PractitionerGUID'].to_s.strip.downcase
      encid = row['ENCID'].to_s.strip
      guid_to_encid[guid] = encid if guid.present? && encid.present?
    end

    imported = 0
    updated  = 0
    skipped  = 0

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

        licensure = ProviderLicensure.find_or_initialize_by(
          provider_attest_id: provider.provider_attest_id,
          license_number: row['license_number'],
          state_id: row['state']
        )

        licensure.assign_attributes(
          caqh_provider_attest_id: provider.caqh_provider_attest_id,
          license_type: row['license_type'],
          license_issue_date: row['license_issue_date'],
          license_expiration_date: row['license_expiration_date'],
          license_comment: row['license_comment'],
          audit_status: row['license_status']
        )

        if licensure.new_record?
          imported += 1
        else
          updated += 1
        end

        licensure.save!(validate: false)
      rescue => e
        skipped += 1
        puts "ERROR GUID=#{row['PractitionerGUID']}: #{e.message}"
      end
    end

    puts "Imported: #{imported}"
    puts "Updated : #{updated}"
    puts "Skipped : #{skipped}"
  end
end