# lib/tasks/import_provider_deas.rake
namespace :data do
  desc "Import DEA numbers from Ins_tbl_X_DEA_Number_202508021611.csv into provider_deas"
  task import_deas: :environment do
    require "csv"

    def parse_date(value)
      return nil if value.blank?
      begin
        Date.strptime(value.strip, "%m/%d/%Y")
      rescue ArgumentError
        begin
          Date.parse(value)
        rescue ArgumentError
          nil
        end
      end
    end

    dea_file   = Rails.root.join("public", "hvhs_csvs", "Ins_tbl_X_DEA_Number_202508021611.csv")
    tbl_x_file = Rails.root.join("public", "hvhs_csvs", "tbl_X_202508021611.csv")

    [dea_file, tbl_x_file].each do |f|
      unless File.exist?(f)
        puts "❌ Missing CSV file: #{f}"
        exit
      end
    end

    # 1️⃣ Build lookup: tbl_X_ID → PractitionerGUID
    tbl_x_lookup = {}
    CSV.foreach(tbl_x_file, headers: true, encoding: "bom|utf-8") do |row|
      tbl_x_lookup[row["tbl_X_ID"]] = row["PractitionerGUID"]
    end

    puts "📥 Importing DEA numbers from #{dea_file}"

    # 2️⃣ Process DEA CSV
    CSV.foreach(dea_file, headers: true, encoding: "bom|utf-8") do |row|
      tbl_x_id          = row["tbl_X_ID"]
      practitioner_guid = tbl_x_lookup[tbl_x_id]

      unless practitioner_guid
        puts "⚠️ Skipping DEA row with tbl_X_ID #{tbl_x_id} (no PractitionerGUID found)"
        next
      end

      ppi = ProviderPersonalInformation.find_by(practitioner_guid: practitioner_guid)
      unless ppi
        puts "⚠️ Skipping DEA row with PractitionerGUID #{practitioner_guid} (no PPI found)"
        next
      end

      # ✅ Build schedules_held from multiple fields
      schedules = []
      schedules << "Full" if row["DEAScheduleFull"].to_s == "1"
      schedules << "2"    if row["DEASchedule2"].to_s == "1"
      schedules << "2N"   if row["DEASchedule2N"].to_s == "1"
      schedules << "3"    if row["DEASchedule3"].to_s == "1"
      schedules << "3N"   if row["DEASchedule3N"].to_s == "1"
      schedules << "4"    if row["DEASchedule4"].to_s == "1"
      schedules << "5"    if row["DEASchedule5"].to_s == "1"

      dea = ProviderDea.new(
        caqh_provider_deaid: row["Ins_tbl_X_DEA_Number_ID"], # PK from DEA table
        provider_attest_id: ppi.provider_attest_id,
        caqh_provider_attest_id: ppi.caqh_provider_id,

        dea_number: row["DEARegisNum"],
        expiration_date: parse_date(row["DEAExpDate"]),
        dea_license_limitation_flag: row["DEALimitedOrNot"].to_s == "1",
        dea_license_limitation_explanation: row["DEALimitedExplanation"],
        no_dea_explanation: row["NoDEAExplanation"],
        application_date: parse_date(row["DEAIssueDate"]),

        # 🔥 Fix booleans (ensure true/false is saved)
        show_on_tickler: row["ShowOnTickler"].to_s == "1" ? 'Yes' : 'No',
        full_schedule:   row["DEAScheduleFull"].to_s == "1" ? 'Yes' : 'No',

        # 🔥 Ensure array is always stored properly
        schedules_held: schedules.presence || []
      )

      # ✅ Map state via alpha_code
      state = State.find_by(alpha_code: row["State"])
      if state
        dea.state = state.id
      else
        puts "⚠️ State not found for code #{row['State']} (DEA #{dea.dea_number})"
        dea.state = nil
      end

      if dea.save(validate: false)
        puts "✅ Saved DEA for PractitionerGUID #{practitioner_guid} (DEA: #{dea.dea_number}, schedules: #{schedules.join(",")})"
      else
        puts "❌ Failed to save DEA for PractitionerGUID #{practitioner_guid}"
      end
    end

    puts "🎉 DEA import completed!"
  end
end
