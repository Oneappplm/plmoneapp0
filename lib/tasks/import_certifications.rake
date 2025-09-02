# lib/tasks/import_provider_specialties.rake
namespace :data do
  desc "Import provider specialties from tbl_VIII_202508021611.csv into provider_specialties"
  task import_certifications: :environment do
    require "csv"

    def parse_date(value)
      return nil if value.blank?
      begin
        Date.strptime(value.strip, "%m/%d/%Y")
      rescue ArgumentError
        nil
      end
    end

    main_file         = Rails.root.join("public", "hvhs_csvs", "tbl_VIII_202508021611.csv")
    specialties_file  = Rails.root.join("public", "hvhs_csvs", "Comm_tbl_Specialties_202508021611.csv")
    board_status_file = Rails.root.join("public", "hvhs_csvs", "Comm_tbl_BoardCertificateStatus_202508021611.csv")
    issue_board_file  = Rails.root.join("public", "hvhs_csvs", "Comm_tbl_IssueBoard_202508021611.csv")

    [main_file, specialties_file, board_status_file, issue_board_file].each do |f|
      unless File.exist?(f)
        puts "❌ Missing CSV file: #{f}"
        exit
      end
    end

    # 1️⃣ Load lookup hashes
    specialties_lookup = {}
    CSV.foreach(specialties_file, headers: true, encoding: "bom|utf-8") do |row|
      specialties_lookup[row["Comm_tbl_Specialties_ID"]] = row["SpecialtyName"]
    end

    board_status_lookup = {}
    CSV.foreach(board_status_file, headers: true, encoding: "bom|utf-8") do |row|
      board_status_lookup[row["Comm_tbl_BoardCertificateStatus_ID"]] = row["BoardCertificateStatus"]
    end

    issue_board_lookup = {}
    CSV.foreach(issue_board_file, headers: true, encoding: "bom|utf-8") do |row|
      issue_board_lookup[row["Comm_tbl_IssueBoard_ID"]] = row["IssuingBoardName"]
    end

    puts "📥 Importing provider specialties from #{main_file}"

    # 2️⃣ Process main CSV
    CSV.foreach(main_file, headers: true, encoding: "bom|utf-8") do |row|
      practitioner_guid = row["PractitionerGUID"]

      ppi = ProviderPersonalInformation.find_by(practitioner_guid: practitioner_guid)
      unless ppi
        puts "⚠️ Skipping row with PractitionerGUID #{practitioner_guid} (no PPI found)"
        next
      end

      # Lookups (map IDs from main CSV to names)
      specialty_name = specialties_lookup[row["Specialty"]]
      board_status   = board_status_lookup[row["BoardCertStatus"]]
      issuing_board  = issue_board_lookup[row["IssuingBoard"]]

      specialty = ProviderSpecialty.new(
        provider_attest_id: ppi.provider_attest_id, # ⚠️ use .id instead of provider_attest_id
        caqh_provider_attest_id: ppi.caqh_provider_id,
        caqh_provider_specialty_id: row["tbl_VIII_ID"],

        # ✅ Use names from lookup tables
        specialty_specialty_name: specialty_name,
        board_certified_flag: board_status,
        specialty_board_name: issuing_board,

        certification_number: row["BoardCertificationNumber"],
        status_expiration_date: parse_date(row["StatusExpDate"]),
        exam_taken_date: parse_date(row["ExamDate"]),
        planning_to_take_board_exam_flag: row["TakeBoardExamOrNot"].to_s.downcase == "yes",
        board_exam_explanation: row["NotTakeExplanation"],
        failed_board_exam_flag: row["ExamPassOrFail"].to_s.downcase == "fail",
        failed_board_exam_explanation: row["FailExplanation"],
        initial_certification_date: parse_date(row["InitialCertDate"]),
        recertification_date: parse_date(row["LastReCertDate"]),
        expiration_date: parse_date(row["CertExpDate"]),
        board_certification_expires_flag: row["CertNotExpire"].to_s.downcase != "yes",
        list_in_directory_flag: row["ListedOrNot"].to_s.downcase == "yes",
        comments: row["Comments"],
        audit_status: row["QualityAuditComplete"].present? ? "Quality Audited" : "Pending",
        applied_board_certificate: row["AppliedBoardCertification"],
        certification_name: row["CertificationName"],
        abms_flag: row["ABMSUID"].present?,
        tickler: row["ShowOnTickler"].to_s.downcase == "yes",
        date_applied: parse_date(row["ApplyDate"])
      )

      specialty.save(validate: false) # skip validations
    end

    puts "✅ Import completed!"
  end
end
