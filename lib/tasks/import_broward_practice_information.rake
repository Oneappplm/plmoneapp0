require 'csv'

namespace :broward do
  desc 'Import Broward practice information records'
  task import_practice_information: :environment do
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

        practice = PracticeInformation.find_or_initialize_by(
          provider_attest_id: provider.provider_attest_id,
          caqh_provider_practice_id: row['caqh_provider_practice_id']
        )

        practice.assign_attributes(
          caqh_provider_attest_id: provider.caqh_provider_attest_id,
          npi: row['npi'],
          tin_number: row['tin_number'],
          address: row['address'],
          address2: row['address2'],
          city: row['city'],
          state: row['state'],
          zip: row['zip'],
          ext_zip: row['ext_zip'],
          phone_number: row['phone_number'],
          fax_number: row['fax_number']
        )

        if practice.new_record?
          imported += 1
        else
          updated += 1
        end

        practice.save!(validate: false)
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