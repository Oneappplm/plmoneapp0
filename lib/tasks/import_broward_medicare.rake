require 'csv'

namespace :broward do
  desc 'Import Broward Medicare billing records'
  task import_medicare: :environment do
    file = ENV.fetch('FILE')
    provider_file = ENV.fetch('PROVIDER_FILE')

    guid_to_encid = {}

    CSV.foreach(provider_file, headers: true) do |row|
      guid = row['PractitionerGUID'].to_s.strip.downcase
      encid = row['ENCID'].to_s.strip
      guid_to_encid[guid] = encid if guid.present? && encid.present?
    end

    imported = 0
    updated  = 0
    skipped  = 0

    bool = lambda do |value|
      value.to_s.strip == '1' || value.to_s.strip.downcase == 'true'
    end

    CSV.foreach(file, headers: true) do |row|
      begin
        guid = row['PractitionerGUID'].to_s.strip.downcase
        encid = guid_to_encid[guid]

        provider = ProviderPersonalInformation.find_by(
          encompass_id_text: encid,
          legacy_client_name: 'Broward Health'
        )

        provider ||= ProviderPersonalInformation.find_by(
          legacy_client_name: 'Broward Health',
          ssn: row['SSN'].to_s.strip
        ) if row.headers.include?('SSN')

        unless provider
          skipped += 1
          puts "Provider not found: GUID=#{guid}, ENCID=#{encid}"
          next
        end

        medicare_number = row['medicare_number'].to_s.strip
        state = row['state'].to_s.strip
        issue_date = row['issue_date'].presence
        caqh_provider_medicare_id = row['caqh_provider_medicare_id'].presence

        medicare =
          if caqh_provider_medicare_id.present?
            ProviderMedicare.find_or_initialize_by(
              provider_attest_id: provider.provider_attest_id,
              caqh_provider_medicare_id: caqh_provider_medicare_id
            )
          else
            ProviderMedicare.find_or_initialize_by(
              provider_attest_id: provider.provider_attest_id,
              medicare_number: medicare_number,
              state: state,
              issue_date: issue_date
            )
          end

        medicare.assign_attributes(
          caqh_provider_attest_id: provider.caqh_provider_attest_id,
          medicare_number: medicare_number,
          state: state,
          issue_date: issue_date,
          medicare_opt_in: bool.call(row['medicare_opt_in']),
          medicare_opt_out: bool.call(row['medicare_opt_out']),
          medicare_partial: bool.call(row['medicare_partial'])
        )

        if medicare.new_record?
          imported += 1
        else
          updated += 1
        end

        medicare.save!(validate: false)
      rescue => e
        skipped += 1
        puts "ERROR GUID=#{row['PractitionerGUID']}: #{e.class} - #{e.message}"
      end
    end

    puts "Imported: #{imported}"
    puts "Updated : #{updated}"
    puts "Skipped : #{skipped}"

    begin
      File.delete(file) if File.exist?(file)
      puts "Deleted import file: #{file}"
    rescue => e
      puts "Could not delete import file: #{file} - #{e.message}"
    end
  end
end