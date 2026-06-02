# lib/tasks/update_provider_licensure_states.rake

require 'csv'

namespace :provider_licensure do
  desc "Update provider licensure states from CSV"

  task update_states: :environment do
    csv_path = ENV['CSV_PATH']

    unless csv_path.present? && File.exist?(csv_path)
      puts "CSV_PATH missing or file does not exist"
      puts "Usage:"
      puts "bundle exec rake provider_licensure:update_states CSV_PATH=tmp/provider_states.csv"
      exit
    end

    updated = 0
    skipped = 0
    errors  = 0

    CSV.foreach(csv_path, headers: true) do |row|
      begin
        prac_id = row['PracID']&.strip
        states  = row['States']&.split(',')&.map(&:strip)

        next if prac_id.blank?
        next if states.blank?

        attest_id = prac_id.gsub('ENC', '').to_i

        licensures =
          ProviderLicensure.where(caqh_provider_attest_id: attest_id)

        if licensures.blank?
          puts "No ProviderLicensure found for #{prac_id}"
          skipped += 1
          next
        end

        state_ids =
          State.where(abbreviation: states).pluck(:id)

        if state_ids.blank?
          puts "No matching states found for #{prac_id}: #{states.join(',')}"
          skipped += 1
          next
        end

        licensures.find_each do |licensure|
          licensure.update!(
            state_id: state_ids.first
          )

          puts "Updated #{prac_id} -> #{states.first}"
          updated += 1
        end
      rescue => e
        puts "ERROR #{prac_id}: #{e.message}"
        errors += 1
      end
    end

    puts
    puts "========== SUMMARY =========="
    puts "Updated : #{updated}"
    puts "Skipped : #{skipped}"
    puts "Errors  : #{errors}"
  end
end