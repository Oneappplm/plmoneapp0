module Reports
  class BcbsReportValidator
    EXPECTED_KEYS = [
      :client_name,
      :batch_description,
      :batch_date,
      :bcbs_party_id,
      :bcbsfl_id,
      :caqh_id,
      :client_alternate_id,
      :npi,
      :first_name,
      :middle_name,
      :last_name,
      :practitioner_type,
      :social_security_number,
      :date_of_birth,
      :cred_recred_status,
      :committee_date,
      :internal_committee_date,
      :app_received_date,
      :app_received_complete_date,
      :submitted_date,
      :complete_profile_return_date,
      :incomplete_profile_return_date,
      :current_psv,
      :signature_date,
      :lia_exp_date,
      :lic_exp_date,
      :dea_exp_date,
      :in_audit,
      :in_collection,
      :in_completion,
      :returned,
      :provider_status,
      :psv_age,
      :psv_tat,
      :returned_within_parameters,
      :app_age,
      :app_tat,
      :number_of_collection_attempts,
      :app_tracker_id,
      :collection_items,
      :first_collection_attempt,
      :app_tracker_comment,
      :app_tracker_comment_date,
      :app_tracker_contact_method,
      :app_tracker_contact_status,
      :credential_contact_phone,
      :credential_contact_fax,
      :profile_generation_date,
      :region,
      :pims_id,
      :practice_state,
      :primary_specialty,
      :latest_edu,
      :npdb_verified_date,
      :npdb_adverse_action,
      :vrc_review_level,
      :vrc_committee_date,
      :vrc_psv_date,
      :vrc_status,
      :qa_reason,
      :vrc_date_reopened,
      :apptracking_comments,
      :outputfile_date,
      :review_detail
    ].freeze

    attr_reader :client_name, :npi

    def initialize(client_name:, npi: nil)
      @client_name = client_name
      @npi = npi
    end

    def call
      rows =
        Reports::BcbsDetailReportDataBuilder
          .new(client_name: client_name)
          .call

      row =
        if npi.present?
          rows.find { |item| item[:npi].to_s == npi.to_s }
        else
          rows.first
        end

      return { error: "No report row found" } unless row

      {
        client_name: client_name,
        provider_npi: row[:npi],
        expected_field_count: EXPECTED_KEYS.count,
        actual_field_count: row.keys.count,
        missing_keys: EXPECTED_KEYS - row.keys,
        extra_keys: row.keys - EXPECTED_KEYS,
        blank_fields: blank_fields(row),
        populated_fields: populated_fields(row),
        row: row
      }
    end

    private

    def blank_fields(row)
      EXPECTED_KEYS.each_with_object({}) do |key, result|
        result[key] = row[key] if row[key].blank?
      end
    end

    def populated_fields(row)
      EXPECTED_KEYS.each_with_object({}) do |key, result|
        value = row[key]
        result[key] = value unless value.blank?
      end
    end
  end
end
