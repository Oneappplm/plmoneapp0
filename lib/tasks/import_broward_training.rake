require 'csv'

namespace :broward do
  desc 'Import Broward training records'
  task import_training: :environment do
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

        education = ProviderEducation.find_or_initialize_by(
          provider_attest_id: provider.provider_attest_id,
          caqh_provider_education_id: row['tbl_V_ID']
        )

        education.assign_attributes(
          caqh_provider_attest_id: provider.caqh_provider_attest_id,
          institution_name: row['InstitutionName'],
          address: row['Address'],
          address2: row['Address2'],
          city: row['City'],
          state: row['State'],
          postal_code: row['Zip'],
          phone_number: row['Phone'],
          fax_number: row['FAX'],
          email_address: row['Email'],
          start_date: row['DateAttendedFrom'],
          end_date: row['DateAttendedTo'],
          program_completed_flag: row['CompletedOrNot'],
          apa_approved_flag: row['APAApproved'],
          program_director: [row['ProgramDirectorFirstName'], row['ProgramDirectorLastName']].compact.join(' ').strip,
          current_program_director_flag: row['CurrentProgramDirector'],
          current_program_director: row['CurrentDirectorList'],
          incomplete_explanation: row['Explanation'],
          program_type: row['TrainingType'],
          specialty_specialty_name: row['SpecialtyName'],
          training_area: row['SpecialtyName'],
          education_type_name: 'Training',
          comments: row['Comments'],
          suite: row['Suite'],
          show_on_tickler: row['ShowOnTickler'],
          audit_status: row['QualityAuditComplete'].to_s == '1' ? 'Quality Audited' : nil
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