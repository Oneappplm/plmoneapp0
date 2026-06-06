require 'csv'

namespace :broward do
  desc 'Import Broward employment records'
  task import_employment: :environment do
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

        employment = ProviderEmployment.find_or_initialize_by(
          provider_attest_id: provider.provider_attest_id,
          caqh_provider_employment_id: row['tbl_III_ID']
        )

        employment.assign_attributes(
          employer_name: row['employer_name'],
          title: row['title'],
          contact_first_name: row['contact_name'],

          address: row['address'],
          mail_stop: row['mail_stop'],
          additional_address: row['additional_address'],
          city: row['city'],
          county: row['county'],
          state: row['state'],
          country: row['country'],
          zip: row['zip'],

          phone_number: row['phone_number'],
          fax: row['fax'],
          email: row['email'],

          from_date: row['from_date'],
          comments: row['comments'],

          show_on_tickler: row['PrimaryOffice'],
          audit_status: row['QualityAuditComplete'].to_s == '1' ? 'Quality Audited' : nil
        )

        if employment.new_record?
          imported += 1
        else
          updated += 1
        end

        employment.save!(validate: false)
      rescue => e
        skipped += 1
        puts "ERROR GUID=#{row['PractitionerGUID']}: #{e.message}"
      end
    end

    puts "Imported: #{imported}"
    puts "Updated : #{updated}"
    puts "Skipped : #{skipped}"

    if skipped == 0
      begin
        File.delete(file) if File.exist?(file)
        puts "Deleted import file: #{file}"
      rescue => e
        puts "Could not delete import file: #{file} - #{e.message}"
      end
    end
  end
end