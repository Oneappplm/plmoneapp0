module Reports
  class BcbsDetailReportDataBuilder
    RETURN_PARAMETER_DAYS = 30

    attr_reader :client_name

    def initialize(client_name:)
      @client_name = client_name.to_s.strip
    end

    def call
      providers.map do |ppi|
        build_row(ppi)
      end
    end

    private

    # =========================================================
    # PROVIDERS
    # =========================================================

    def providers
      ProviderPersonalInformation
        .where(legacy_client_name: client_name)
        .includes(
          :provider_personal_information_app_trackings,
          :provider_personal_information_credentialing_contact,
          :provider_licensures,
          :provider_deas,
          :provider_insurance_coverages,
          :provider_educations,
          :provider_specialties,
          :provider_personal_attempts,
          :rva_informations,
          :review_level_changes
        )
        .order(:last_name, :first_name)
    end

    # =========================================================
    # MAIN ROW
    # =========================================================

    def build_row(ppi)
      tracking = latest_tracking(ppi)

      contact =
        ppi.provider_personal_information_credentialing_contact

      license =
        latest_license(ppi)

      dea =
        latest_dea(ppi)

      insurance =
        latest_insurance(ppi)

      education =
        latest_education(ppi)

      specialty =
        primary_specialty(ppi)

      npdb_rva =
        latest_npdb_rva(ppi)

      attempts =
        collection_attempts(ppi)

      first_attempt =
        attempts.min_by do |attempt|
          attempt.contact_date || Date.new(1900, 1, 1)
        end

      latest_attempt =
        attempts.max_by do |attempt|
          attempt.contact_date || Date.new(1900, 1, 1)
        end

      vrc =
        latest_vrc(ppi)

      review_change =
        latest_review_change(ppi)

      {
        # =====================================================
        # CLIENT / BATCH
        # =====================================================

        client_name:
          ppi.legacy_client_name,

        batch_description:
          ppi.client_batch_name,

        batch_date:
          ppi.client_batch_date,

        # =====================================================
        # CLIENT IDS
        # =====================================================

        bcbs_party_id:
          ppi.plan_provider_id,

        bcbsfl_id:
          ppi.nid,

        caqh_id:
          first_present(
            ppi.caqh_provider_attest_id,
            ppi.caqh_provider_id
          ),

        client_alternate_id:
          first_present(
            ppi.encompass_id_text,
            ppi.provider_attest_id
          ),

        # =====================================================
        # PROVIDER DEMOGRAPHICS
        # =====================================================

        npi:
          ppi.npi,

        first_name:
          ppi.first_name,

        middle_name:
          ppi.middle_name,

        last_name:
          ppi.last_name,

        practitioner_type:
          ppi.practitioner_type,

        social_security_number:
          ppi.ssn,

        date_of_birth:
          first_present(
            safe_attribute(ppi, :date_of_birth),
            safe_attribute(ppi, :birth_date)
          ),

        # =====================================================
        # CREDENTIAL / RECREDENTIAL
        # =====================================================

        cred_recred_status:
          first_present(
            ppi.cred_cycle,
            ppi.application_type
          ),

        committee_date:
          first_present(
            safe_attribute(vrc, :committee_date),
            ppi.committee_date
          ),

        internal_committee_date:
          first_present(
            ppi.credentials_committee_date,
            ppi.review_date
          ),

        # =====================================================
        # APPLICATION TRACKING
        # =====================================================

        app_received_date:
          safe_attribute(
            tracking,
            :application_receipt_date
          ),

        app_received_complete_date:
          safe_attribute(
            tracking,
            :application_receive_complete_date
          ),

        submitted_date:
          safe_attribute(
            tracking,
            :application_submitted_date
          ),

        complete_profile_return_date:
          complete_profile_return_date(tracking),

        incomplete_profile_return_date:
          incomplete_profile_return_date(tracking),

        # =====================================================
        # PSV
        # =====================================================

        current_psv:
          current_psv(ppi),

        signature_date:
          ppi.signature_date,

        # =====================================================
        # EXPIRATIONS
        # =====================================================

        lia_exp_date:
          safe_attribute(
            insurance,
            :end_date
          ),

        lic_exp_date:
          safe_attribute(
            license,
            :license_expiration_date
          ),

        dea_exp_date:
          safe_attribute(
            dea,
            :expiration_date
          ),

        # =====================================================
        # WORKFLOW FLAGS
        # =====================================================

        in_audit:
          audit_status_value(npdb_rva),

        in_collection:
          collection_status(attempts),

        in_completion:
          completion_status(ppi),

        returned:
          returned_status(tracking),

        provider_status:
          first_present(
            ppi.status,
            ppi.cred_status
          ),

        # =====================================================
        # CALCULATIONS
        # =====================================================

        psv_age:
          psv_age(ppi),

        psv_tat:
          psv_tat(ppi, tracking),

        returned_within_parameters:
          returned_within_parameters(tracking),

        app_age:
          application_age(tracking),

        app_tat:
          application_tat(tracking),

        # =====================================================
        # COLLECTION
        # =====================================================

        number_of_collection_attempts:
          attempts.size,

        app_tracker_id:
          safe_attribute(
            tracking,
            :id
          ),

        collection_items:
          collection_items(attempts),

        first_collection_attempt:
          safe_attribute(
            first_attempt,
            :contact_date
          ),

        app_tracker_comment:
          first_present(
            safe_attribute(
              tracking,
              :application_comment
            ),
            safe_attribute(
              tracking,
              :other_comment
            )
          ),

        app_tracker_comment_date:
          safe_attribute(
            tracking,
            :updated_at
          ),

        app_tracker_contact_method:
          safe_attribute(
            latest_attempt,
            :contact_method
          ),

        app_tracker_contact_status:
          safe_attribute(
            latest_attempt,
            :attempt_status
          ),

        # =====================================================
        # CREDENTIALING CONTACT
        # =====================================================

        credential_contact_phone:
          safe_attribute(
            contact,
            :phone_number
          ),

        credential_contact_fax:
          first_present(
            safe_attribute(
              contact,
              :fax_number
            ),
            safe_attribute(
              contact,
              :fax
            )
          ),

        # =====================================================
        # PROFILE
        # =====================================================

        profile_generation_date:
          Date.current,

        region:
          first_present(
            safe_attribute(
              vrc,
              :region
            ),
            ppi.market
          ),

        pims_id:
          first_present(
            ppi.encompass_id_text,
            safe_attribute(vrc, :medv_id)
          ),

        practice_state:
          first_present(
            ppi.primary_practice_state,
            ppi.state
          ),

        primary_specialty:
          first_present(
            safe_attribute(
              specialty,
              :specialty_specialty_name
            ),
            ppi.specialty_name_1
          ),

        latest_edu:
          latest_education_value(education),

        # =====================================================
        # NPDB
        # =====================================================

        npdb_verified_date:
          safe_attribute(
            npdb_rva,
            :verification_date
          ),

        npdb_adverse_action:
          first_present(
            safe_attribute(
              npdb_rva,
              :adverse_action
            ),
            safe_attribute(
              npdb_rva,
              :adverse_action_status
            ),
            "No"
          ),

        # =====================================================
        # VRC
        # =====================================================

        vrc_review_level:
          first_present(
            safe_attribute(
              vrc,
              :review_level
            ),
            ppi.review_level
          ),

        vrc_committee_date:
          first_present(
            safe_attribute(
              vrc,
              :committee_date
            ),
            ppi.committee_date
          ),

        vrc_psv_date:
          first_present(
            safe_attribute(
              vrc,
              :psv_completed_date
            ),
            ppi.psv_completed_date
          ),

        vrc_status:
          first_present(
            safe_attribute(
              vrc,
              :status
            ),
            ppi.status
          ),

        # =====================================================
        # QA
        # =====================================================

        qa_reason:
          first_present(
            safe_attribute(
              npdb_rva,
              :audit_reason
            ),
            safe_attribute(
              npdb_rva,
              :audit_reason_comments
            )
          ),

        # =====================================================
        # VRC REOPEN / REVIEW HISTORY
        # =====================================================

        vrc_date_reopened:
          safe_attribute(
            review_change,
            :created_at
          ),

        # =====================================================
        # COMMENTS
        # =====================================================

        apptracking_comments:
          app_tracking_comments(tracking),

        outputfile_date:
          Date.current,

        review_detail:
          first_present(
            safe_attribute(
              vrc,
              :review_details
            ),
            ppi.review_details,
            safe_attribute(
              review_change,
              :reason
            )
          )
      }
    end

    # =========================================================
    # ASSOCIATED RECORD HELPERS
    # =========================================================

    def latest_tracking(ppi)
      ppi
        .provider_personal_information_app_trackings
        .max_by do |record|
          record.updated_at ||
            record.created_at ||
            Time.zone.local(1900, 1, 1)
        end
    end

    def latest_license(ppi)
      ppi
        .provider_licensures
        .compact
        .max_by do |record|
          record.license_expiration_date ||
            Date.new(1900, 1, 1)
        end
    end

    def latest_dea(ppi)
      ppi
        .provider_deas
        .compact
        .max_by do |record|
          record.expiration_date ||
            Time.zone.local(1900, 1, 1)
        end
    end

    def latest_insurance(ppi)
      ppi
        .provider_insurance_coverages
        .compact
        .max_by do |record|
          record.end_date ||
            Time.zone.local(1900, 1, 1)
        end
    end

    def latest_education(ppi)
      ppi
        .provider_educations
        .compact
        .max_by do |record|
          record.completion_date ||
            record.end_date ||
            Time.zone.local(1900, 1, 1)
        end
    end

    def primary_specialty(ppi)
      ppi
        .provider_specialties
        .find do |record|
          record.specialty_specialty_name.present?
        end
    end

    def latest_npdb_rva(ppi)
      ppi
        .rva_informations
        .select do |record|
          record.tab.to_s.casecmp("NPDB").zero?
        end
        .max_by do |record|
          record.verification_date ||
            record.updated_at ||
            record.created_at
        end
    end

    def collection_attempts(ppi)
      ppi
        .provider_personal_attempts
        .sort_by do |record|
          record.contact_date ||
            Date.new(1900, 1, 1)
        end
    end

    def latest_review_change(ppi)
      ppi
        .review_level_changes
        .max_by do |record|
          record.updated_at ||
            record.created_at
        end
    end

    def latest_vrc(ppi)
      return nil unless defined?(VirtualReviewCommittee)

      VirtualReviewCommittee
        .where(provider_id: ppi.id)
        .order(
          committee_date: :desc,
          created_at: :desc
        )
        .first
    end

    # =========================================================
    # PSV CALCULATIONS
    # =========================================================

    def current_psv(ppi)
      return "Completed" if ppi.psv_completed_date.present?

      first_present(
        ppi.verification_status,
        ppi.cred_status
      )
    end

    def psv_age(ppi)
      days_between(
        ppi.psv_completed_date,
        Date.current
      )
    end

    def psv_tat(ppi, tracking)
      return nil unless tracking

      days_between(
        tracking.application_receipt_date,
        ppi.psv_completed_date
      )
    end

    # =========================================================
    # APPLICATION CALCULATIONS
    # =========================================================

    def application_age(tracking)
      return nil unless tracking

      days_between(
        tracking.application_receipt_date,
        Date.current
      )
    end

    def application_tat(tracking)
      return nil unless tracking

      completed_date =
        first_present(
          tracking.file_return_to_client_date,
          tracking.verification_complete_date
        )

      days_between(
        tracking.application_receipt_date,
        completed_date
      )
    end

    # =========================================================
    # RETURN STATUS
    # =========================================================

    def complete_profile_return_date(tracking)
      return nil unless tracking

      status =
        tracking.file_status.to_s.downcase

      return nil if status.include?("incomplete")

      tracking.file_return_to_client_date
    end

    def incomplete_profile_return_date(tracking)
      return nil unless tracking

      status =
        tracking.file_status.to_s.downcase

      return nil unless status.include?("incomplete")

      tracking.file_return_to_client_date
    end

    def returned_status(tracking)
      return "No" unless tracking

      tracking.file_return_to_client_date.present? ? "Yes" : "No"
    end

    def returned_within_parameters(tracking)
      return "No" unless tracking

      received =
        tracking.application_receipt_date

      returned =
        tracking.file_return_to_client_date

      return "No" if received.blank? || returned.blank?

      tat =
        days_between(
          received,
          returned
        )

      tat.present? &&
        tat <= RETURN_PARAMETER_DAYS ? "Yes" : "No"
    end

    # =========================================================
    # WORKFLOW STATUS
    # =========================================================

    def audit_status_value(rva)
      return "No" unless rva

      rva.audit_status == true ? "Yes" : "No"
    end

    def collection_status(attempts)
      attempts.any? ? "Yes" : "No"
    end

    def completion_status(ppi)
      first_present(
        ppi.progress_status,
        ppi.verification_status,
        ppi.cred_status
      ).to_s
    end

    # =========================================================
    # COLLECTION
    # =========================================================

    def collection_items(attempts)
      attempts
        .map do |attempt|
          [
            attempt.contact_date,
            attempt.contact_method,
            attempt.attempt_status,
            attempt.comments
          ]
            .reject(&:blank?)
            .join(" - ")
        end
        .reject(&:blank?)
        .join(" | ")
        .presence
    end

    # =========================================================
    # COMMENTS
    # =========================================================

    def app_tracking_comments(tracking)
      return nil unless tracking

      [
        tracking.application_comment,
        tracking.other_comment
      ]
        .reject(&:blank?)
        .join(" | ")
        .presence
    end

    # =========================================================
    # EDUCATION
    # =========================================================

    def latest_education_value(education)
      return nil unless education

      [
        education.institution_name,
        education.program_title,
        education.degree_degree_abbreviation
      ]
        .reject(&:blank?)
        .join(" - ")
        .presence
    end

    # =========================================================
    # GENERIC HELPERS
    # =========================================================

    def days_between(start_value, end_value)
      return nil if start_value.blank? || end_value.blank?

      start_date =
        start_value.to_date

      end_date =
        end_value.to_date

      (end_date - start_date).to_i
    rescue StandardError
      nil
    end

    def safe_attribute(record, attribute)
      return nil unless record
      return nil unless record.respond_to?(attribute)

      record.public_send(attribute)
    end

    def first_present(*values)
      values.find(&:present?)
    end
  end
end
