require "csv"

namespace :legacy do
  desc "Import legacy provider training records"
  task import_provider_trainings: :environment do
    file = ENV.fetch("FILE")

    imported = 0
    skipped = 0

    CSV.foreach(file, headers: true) do |row|
      ppi = ProviderPersonalInformation.find_by(encompass_id_text: row["PracID"])

      unless ppi
        skipped += 1
        next
      end

      next if row["InstitutionName"].blank?

      training = ProviderEducation.find_or_initialize_by(
        provider_attest_id: ppi.provider_attest_id,
        caqh_provider_attest_id: ppi.caqh_provider_attest_id,
        institution_name: row["InstitutionName"],
        program_type: row["TrainingType"],
        specialty_specialty_name: row["specialty"],
        start_date: row["AttendedFrom"]
      )

      training.end_date = row["AttendedTo"]
      training.program_completed_flag = row["CompletedOrNot"]
      training.incomplete_explanation = row["Explanation"]
      training.training_area = row["specialty"]
      training.program_title = row["TrainingType"]
      training.education_type_name = "Training"
      training.audit_status = row["VerifiedStatus"]
      training.comments = row["Comments"]

      training.save!(validate: false)
      imported += 1
    end

    puts "Provider training import completed"
    puts "Imported/updated: #{imported}"
    puts "Skipped: #{skipped}"
  end
end