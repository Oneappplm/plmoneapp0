# lib/tasks/update_provider_licensure_states.rake

require 'csv'

namespace :provider_licensure do
  desc "Update provider licensure states from CSV"

  task update_states: :environment do
    csv_path = ENV['CSV_PATH']

    unless csv_path.present? && File.exist?(csv_path)
      puts "CSV_PATH missing or file does not exist"
      puts "Usage:"
      puts "bundle exec rake provider_licensure:update_states CSV_PATH=/tmp/provider_states.csv"
      exit
    end

    updated = 0
    skipped = 0
    errors  = 0

    CSV.foreach(csv_path, headers: true) do |row|
      begin
        prac_id = row['PracID']&.strip

        state_value = row['States'] || row['State']

        states =
          state_value.to_s
                     .split(',')
                     .map(&:strip)
                     .reject(&:blank?)
                     .reject { |state| state.upcase == 'NULL' }

        if prac_id.blank?
          skipped += 1
          next
        end

        if states.blank?
          puts "Skipping #{prac_id} - no valid state found"
          skipped += 1
          next
        end

        attest_id = prac_id.gsub('ENC', '').to_i

        licensures =
          ProviderLicensure.where(caqh_provider_attest_id: attest_id)

        if licensures.blank?
          puts "No ProviderLicensure found for #{prac_id}"
          skipped += 1
          next
        end

        state =
          State.find_by(abbreviation: states.first)

        unless state
          puts "No matching state found for #{prac_id}: #{states.first}"
          skipped += 1
          next
        end

        puts "Processing #{prac_id} -> #{state.abbreviation}"

        licensures.find_each do |licensure|
          old_state =
            State.find_by(id: licensure.state_id)&.abbreviation

          licensure.update!(state_id: state.id)

          puts "  Updated Licensure ##{licensure.id}: #{old_state} -> #{state.abbreviation}"

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