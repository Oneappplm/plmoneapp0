namespace :data do
  desc "Import provider licensures from tbl_XI_202508021611.csv"
  task provider_licensures: :environment do
    require 'csv'

    def to_bool(val)
      return false if val.nil?
      normalized = val.to_s.strip.downcase
      %w[1 yes true y].include?(normalized)
    end

    file_path = Rails.root.join("public", "tbl_XI_202508021611.csv")

    unless File.exist?(file_path)
      puts "CSV file not found at #{file_path}"
      next
    end

    puts "Starting import from #{file_path}..."

    CSV.foreach(file_path, headers: true, quote_char: '"', liberal_parsing: true) do |row|
      begin
        # Find provider by PractitionerGUID
        provider = ProviderPersonalInformation.find_by(practitioner_guid: row['PractitionerGUID'])
        unless provider
          puts "⚠️ Provider not found for PractitionerGUID: #{row['PractitionerGUID']}, skipping..."
          next
        end

        # Find or initialize licensure by license_number for this provider
        lic = provider.provider_licensures.find_or_initialize_by(license_number: row['LicenseNumber'])

        # ✅ Always keep provider_attest_id from provider (FK)
        lic.provider_attest_id = provider.provider_attest_id.to_i

        # Map state via alpha_code
        state = State.find_by(alpha_code: row['State'])
        if state
          lic.state_id = state.id
        else
          puts "⚠️ State not found for code #{row['State']} for license #{row['LicenseNumber']}"
          lic.state_id = nil
        end

        # Map CSV columns
        lic.license_type                 = row['Type']
        lic.license_issue_date           = row['IssueDate']
        lic.license_expiration_date      = row['ExpirationDate']
        lic.currently_practice_under_this = to_bool(row['CurrentlyPractice'])
        lic.is_primary_license           = to_bool(row['PrimaryLicense'])
        lic.level_require_supervision    = to_bool(row['LicenseRequireSupervision'])
        lic.failed_state_license_exam    = to_bool(row['LicenseFailed'])
        lic.license_person_type          = row['LicenseType']
        lic.license_comment              = row['ListComments']
        lic.show_on_tickler              = to_bool(row['ShowOnTickler'])
        lic.audit_status                 = row['QualityAuditComplete'].presence || row['OtherQualityAuditComplete'].presence

        # ✅ Save CAQH attest separately
        lic.caqh_provider_attest_id      = row['tbl_InsTable_PhysicianName_ID']

        lic.save!(validate: false)
        puts "✅ Imported/Updated license #{lic.license_number} for provider #{provider.id}"

      rescue => e
        puts "❌ Error importing row #{row['tbl_XI_ID']}: #{e.message}"
      end
    end

    puts "Provider licensures import completed!"
  end
end
