require 'csv'

namespace :data do
  desc "Import provider other names from Ins_tbl_II_OtherName_202508021611.csv"
  task import_provider_other_names: :environment do
    file_path   = Rails.root.join("public", "hvhs_csvs", "Ins_tbl_II_OtherName_202508021611.csv")
    tbl_ii_file = Rails.root.join("public", "hvhs_csvs", "tbl_II_202508021611.csv")

    puts "📂 Importing from #{file_path}..."

    unless File.exist?(file_path) && File.exist?(tbl_ii_file)
      puts "❌ Required CSV file not found."
      next
    end

    # Build lookup for tbl_II_ID -> PractitionerGUID + id
    tbl_ii_lookup = {}
    CSV.foreach(tbl_ii_file, headers: true) do |row|
      tbl_ii_id = row["tbl_II_ID"].to_s.strip
      tbl_ii_lookup[tbl_ii_id] = {
        practitioner_guid: row["PractitionerGUID"].to_s.strip,
        id: row["id"].to_s.strip
      }
    end

    imported = 0
    total    = 0

    CSV.foreach(file_path, headers: true) do |row|
      total += 1
      tbl_ii_id = row["tbl_II_ID"].to_s.strip
      mapping   = tbl_ii_lookup[tbl_ii_id]

      if mapping.blank?
        puts "⚠️ Skipping row #{total}, no PractitionerGUID found for tbl_II_ID #{tbl_ii_id}"
        next
      end

      practitioner_guid = mapping[:practitioner_guid]

      ppi = ProviderPersonalInformation.find_by(practitioner_guid: practitioner_guid)
      unless ppi
        puts "⚠️ Skipping row #{total}, no ProviderPersonalInformation for GUID #{practitioner_guid}"
        next
      end

      other_name = ppi.provider_other_names.find_or_initialize_by(
        caqh_provider_other_name_id: row["Ins_tbl_II_OtherName_ID"]
      )

      other_name.assign_attributes(
        provider_attest_id:      ppi.provider_attest_id,
        caqh_provider_attest_id: ppi.caqh_provider_attest_id,
        first_name:              row["FirstName"],
        middle_name:             row["MiddleName"],
        last_name:               row["LastName"],
        suffix:                  row["Suffix"],
        start_date:              row["DateFrom"],
        end_date:                row["DateTo"],
        name_type:               (row["MaidenName"].to_s.strip.downcase.in?(%w[1 yes true y]) ? "maiden" : "legal"),
        in_use:                  row["DateTo"].blank?
      )

      if other_name.save(validate: false)
        imported += 1
        puts "✅ Imported other name for provider #{ppi.id} (#{other_name.first_name} #{other_name.last_name})"
      else
        puts "❌ Failed row #{total}: #{other_name.errors.full_messages.join(', ')}"
      end
    end

    puts "✅ Finished. Imported #{imported}/#{total} provider other names."
  end
end
