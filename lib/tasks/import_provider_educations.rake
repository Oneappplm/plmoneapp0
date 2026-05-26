require "csv"

namespace :legacy do
  desc "Import legacy provider education records"
  task import_provider_educations: :environment do
    file = ENV.fetch("FILE")

    imported = 0
    skipped = 0

    CSV.foreach(file, headers: true) do |row|
      ppi = ProviderPersonalInformation.find_by(encompass_id_text: row["PracID"])

      unless ppi
        skipped += 1
        next
      end

      next if row["SchoolName"].blank?

      education = ProviderEducation.find_or_initialize_by(
        provider_attest_id: ppi.provider_attest_id,
        caqh_provider_attest_id: ppi.caqh_provider_attest_id,
        institution_name: row["SchoolName"],
        degree_degree_abbreviation: row["DegreeCertificate"]
      )

      education.start_date = row["AttendedFrom"]
      education.end_date = row["AttendedTo"]
      education.program_completed_flag = row["CompletedOrNot"]
      education.incomplete_explanation = row["Explanation"]
      education.audit_status = row["VerifiedStatus"]
      education.comments = row["Comments"]
      education.education_type_name = "Education"

      education.save!(validate: false)
      imported += 1
    end

    puts "Education import completed"
    puts "Imported/updated: #{imported}"
    puts "Skipped: #{skipped}"
  end
end