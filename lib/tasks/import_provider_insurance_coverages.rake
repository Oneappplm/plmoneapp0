require "csv"

namespace :legacy do
  desc "Import legacy provider professional liability insurance records"
  task import_provider_insurance_coverages: :environment do
    file = ENV.fetch("FILE")

    imported = 0
    skipped = 0

    CSV.foreach(file, headers: true) do |row|
      ppi = ProviderPersonalInformation.find_by(encompass_id_text: row["PracID"])

      unless ppi
        skipped += 1
        next
      end

      next if row["PolicyNumber"].blank? && row["CarrierName"].blank?

      insurance = ProviderInsuranceCoverage.find_or_initialize_by(
        provider_attest_id: ppi.provider_attest_id,
        caqh_provider_attest_id: ppi.caqh_provider_attest_id,
        policy_number: row["PolicyNumber"]
      )

      insurance.insurance_carrier_name = row["CarrierName"]
      insurance.policy_holder = row["PolicyHolder"]
      insurance.original_start_date = row["OriginalEffectiveDate"]
      insurance.start_date = row["OriginalEffectiveDate"]
      insurance.effective_date = row["OriginalEffectiveDate"]
      insurance.end_date = row["ExpirationDate"]
      insurance.coverage_amount_occurrence = row["PeerClaimAmount"]
      insurance.coverage_amount_aggregate = row["AggregateAmount"]
      insurance.umbrella_coverage_amount = row["UmbrellaCoverageAmount"]
      insurance.individual_coverage_flag = row["Coverage"]
      insurance.current_carrier_excluded = row["CurCarrierExcludePractice"]
      insurance.current_carrier_excluded_explanation = row["ListExclusions"]
      insurance.comment = row["Comments"]
      insurance.renewal_date = row["VerificationCompleteDate"]
      insurance.claims_history_audit = row["ClaimsHistoryQualityAuditComplete"]
      insurance.audit_status = row["LiabCoverageQualityAuditComplete"]
      insurance.self_insured_flag = row["SelfInsured"]
      insurance.insurance_coverage_type_insurance_coverage_type_description = row["CoverageType"]
      insurance.type_of_policy = row["PolicyType"]
      insurance.phone_number = row["CarrierPhone"]
      insurance.fax_number = row["CarrierFax"]
      insurance.email_address = row["CarrierEmail"]
      insurance.address2 = row["Suite"]
      insurance.show_on_tickler = row["ShowOnTickler"]
      insurance.prof_liability_does_not_expire = row["NotExpire"]
      insurance.form_type = "main"

      insurance.save!(validate: false)
      imported += 1
    end

    puts "Provider insurance coverage import completed"
    puts "Imported/updated: #{imported}"
    puts "Skipped: #{skipped}"
  end
end