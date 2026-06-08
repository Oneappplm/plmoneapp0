require 'csv'

namespace :broward do
  desc 'Import Broward DEA records'
  task import_dea: :environment do
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

        dea = ProviderDea.find_or_initialize_by(
          provider_attest_id: provider.provider_attest_id,
          caqh_provider_deaid: row['caqh_provider_deaid']
        )

        dea.assign_attributes(
          caqh_provider_attest_id: provider.caqh_provider_attest_id,
          dea_number: row['dea_number'],
          expiration_date: row['expiration_date'],
          schedules_held: row['schedules_held'],
          full_schedule: row['schedules_held'],
          dea_license_limitation_explanation: row['dea_status']
        )

        if dea.new_record?
          imported += 1
        else
          updated += 1
        end

        dea.save!(validate: false)
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