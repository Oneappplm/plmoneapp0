require 'csv'

namespace :data do
  desc "Import practice types from Comm_tbl_PracticeType_202508021611.csv"
  task import_practice_types: :environment do
    file_path = Rails.root.join("public", "hvhs_csvs/Comm_tbl_PracticeType_202508021611.csv")
    puts "📂 Importing from #{file_path}..."

    unless File.exist?(file_path)
      puts "❌ CSV file not found at #{file_path}"
      next
    end

    imported = 0
    total = 0

    CSV.foreach(file_path, headers: true) do |row|
      total += 1

      # Skip if PracticeType name is blank
      if row["PracticeType"].blank?
        puts "⚠️ Skipping row #{total} because PracticeType is blank"
        next
      end

      practice_type = PracticeType.find_or_initialize_by(name: row["PracticeType"].strip)

      if practice_type.new_record?
        if practice_type.save
          imported += 1
          puts "✅ Created practice type: #{practice_type.name}"
        else
          puts "❌ Failed to save row #{total}: #{practice_type.errors.full_messages.join(', ')}"
        end
      else
        puts "ℹ️ Already exists: #{practice_type.name}"
      end
    end

    puts "✅ Finished. Imported #{imported}/#{total} new practice types."
  end
end
