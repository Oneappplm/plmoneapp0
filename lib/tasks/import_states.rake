# lib/tasks/import_states.rake
require 'csv'

namespace :data do
  desc "Import states from Comm_tbl_State_202508021611.csv into states table"
  task import_states: :environment do
    file_path = Rails.root.join("public", "Comm_tbl_State_202508021611.csv")

    unless File.exist?(file_path)
      puts "CSV file not found at #{file_path}"
      exit
    end

    puts "Importing states from #{file_path}..."

    CSV.foreach(file_path, headers: true) do |row|
      state_name   = row['State']&.strip
      alpha_code   = row['Comm_tbl_State_ID']&.strip

      state = State.find_or_initialize_by(name: state_name)

      state.alpha_code = alpha_code.presence || state.alpha_code
      state.color      = state.color.presence || "default" # fallback if needed

      if row['DateCreated'].present?
        # Only set created_at if record is new
        state.created_at ||= row['DateCreated'].to_datetime rescue Time.now
      end

      if state.save
        puts "✔ Imported #{state_name} (#{alpha_code})"
      else
        puts "❌ Failed for #{state_name}: #{state.errors.full_messages.join(", ")}"
      end
    end

    puts "✅ Import complete!"
  end
end
