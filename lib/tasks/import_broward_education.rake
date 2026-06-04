require 'csv'

namespace :broward do
  desc 'Import Broward education records'
  task import_education: :environment do
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

        education = PracticeInformationEducation.find_or_initialize_by(
          provider_attest_id: provider.provider_attest_id,
          caqh_practice_information_education_id: row['tbl_IV_ID']
        )

        education.assign_attributes(
          caqh_provider_attest_id: provider.caqh_provider_attest_id,

          institution_name: row['SchoolName'],
          address: row['Address'],
          address2: row['Address2'],
          city: row['City'],
          state: row['State'],
          postal_code: row['Zip'],
          phone_number: row['Phone'],
          fax_number: row['FAX'],
          email_address: row['Email'],

          program_title: row['ProgramTitle'],
          degree_degree_abbreviation: row['DegreeCertificate'],

          start_date: row['DateAttendedFrom'],
          end_date: row['DateAttendedto'],

          program_completed_flag: row['CompletedOrNot'],
          incomplete_explanation: row['Explanation'],

          suite_dept_mail_stop: row['Suite'],
          if_other_list: row['IfOtherFill'],
          comments: row['Comments'],

          show_on_tickler: row['ShowOnTickler'],

          verification_status:
            row['QualityAuditComplete'].to_s == '1' ? 'verified' : 'pending',
        )

        education.new_record? ? imported += 1 : updated += 1
        education.save!(validate: false)
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