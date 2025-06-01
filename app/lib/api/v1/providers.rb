module Api
  module V1
    class Providers < Grape::API

      helpers do
        params :shared_provider_params do
          optional :first_name, type: String, desc: "Provider's first name."
          optional :middle_name, type: String, desc: "Provider's middle name."
          optional :last_name, type: String, desc: "Provider's last name."
          optional :suffix, type: String, desc: "Provider's suffix."
          optional :gender, type: String, desc: "Provider's gender."
          optional :birth_date, type: Date, desc: "Provider's date of birth."
          optional :birth_city, type: String, desc: 'City of birth.'
          optional :birth_state, type: String, desc: 'State of birth.'
          optional :birth_city_state, type: String, desc: 'Combined birth city/state.'
          optional :practitioner_type, type: String, desc: 'Type of practitioner.'
          optional :status, type: String, desc: "Provider's status."
          optional :terminated, type: String, desc: 'Termination status/reason.'
          optional :end_date, type: String, desc: 'End date associated with provider.'
          optional :npi, type: String, desc: "Provider's National Provider Identifier."
          optional :caqhid, type: String, desc: "Provider's CAQH ID."
          optional :caqh_id, type: String, desc: "Provider's CAQH ID (duplicate?)."
          optional :nccpa_number, type: String, desc: "Provider's NCCPA number."
          optional :medicare_provider_number, type: String, desc: 'Medicare provider number.'
          optional :medicaid_provider_number, type: String, desc: 'Medicaid provider number.'
          optional :tricare_provider_number, type: String, desc: 'Tricare provider number.'
          optional :taxonomy, type: String, desc: "Provider's taxonomy code."
          optional :specialty, type: String, desc: "Provider's specialty."
          optional :email_address, type: String, desc: "Provider's email address."
          optional :telephone_number, type: String, desc: "Provider's phone number."
          optional :ext, type: String, desc: 'Phone number extension.'
          optional :address_line_1, type: String, desc: "Provider's address line 1."
          optional :address_line_2, type: String, desc: "Provider's address line 2."
          optional :city, type: String, desc: "Provider's city."
          optional :state_id, type: Integer, desc: "Provider's state ID."
          optional :zip_code, type: String, desc: "Provider's zip code."
          optional :caqh_attestation_date, type: Date, desc: 'CAQH Attestation Date.'
          optional :caqh_pdf, type: String, desc: 'Path/reference to CAQH PDF.'
          optional :caqh_pdf_date_received, type: Date, desc: 'Date CAQH PDF was received.'
          optional :caqh_username, type: String, desc: 'CAQH Username.'
          optional :caqh_state, type: String, desc: 'CAQH State.'
          optional :caqh_app, type: String, desc: 'CAQH App status/reference.'
          optional :caqh_payor, type: String, desc: 'CAQH Payor info.'
          optional :caqh_login, type: String, desc: 'CAQH Login info/status.'
          optional :reattestation_date, type: Date, desc: 'CAQH Reattestation date.'
          optional :security_question_answer, type: String, desc: 'CAQH Security answer.'
          optional :caqh_current_reattestation_date, type: DateTime, desc: 'CAQH Current Reattestation Date.'
          optional :caqh_reattest_completed_by, type: String, desc: 'Who completed CAQH reattestation.'
          optional :caqh_question, type: String, desc: 'CAQH Security question.'
          optional :caqh_answer, type: String, desc: 'CAQH Security answer (duplicate?).'
          optional :caqh_notes, type: String, desc: 'Notes related to CAQH.'
          optional :license_number, type: String, desc: 'Primary license number.'
          optional :license_effective_date, type: String, desc: 'Primary license effective date.'
          optional :license_expiration_date, type: String, desc: 'Primary license expiration date.'
          optional :state_license, type: String, desc: 'State license info/number.'
          optional :state_license_effective_date, type: Date, desc: 'State license effective date.'
          optional :state_license_expiration_date, type: Date, desc: 'State license expiration date.'
          optional :state_license_effectice_date, type: Date, desc: 'State license effective date (duplicate?).'
          optional :license_state_number, type: String, desc: 'License number for specific state.'
          optional :license_state_effective_date, type: String, desc: 'Effective date for specific state license.'
          optional :license_state_id, type: String, desc: 'ID of state for specific license.'
          optional :license_state_expiration_date, type: String, desc: 'Expiration date for specific state license.'
          optional :medical_license, type: String, desc: 'Medical license info/number.'
          optional :state_not_applicable, type: String, desc: 'Reason state license not applicable.'
          optional :license_explain, type: String, desc: 'Explanation for state license.'
          optional :dea_number, type: String, desc: "Provider's DEA number."
          optional :dea_license_effective_date, type: Date, desc: 'DEA license effective date.'
          optional :dea_license_expiration_date, type: Date, desc: 'DEA license expiration date.'
          optional :dea_effective_date, type: String, desc: 'DEA effective date (duplicate?).'
          optional :dea_expiration_date, type: String, desc: 'DEA expiration date (duplicate?).'
          optional :dea_registration_state, type: String, desc: 'State of DEA registration.'
          optional :dea_not_applicable, type: String, desc: 'Reason DEA not applicable.'
          optional :dea_explain, type: String, desc: 'Explanation for DEA.'
          optional :pa_license_effective_date, type: Date, desc: 'PA license effective date.'
          optional :pa_license_expiration_date, type: Date, desc: 'PA license expiration date.'
          optional :pa_license_number, type: String, desc: 'PA license number.'
          optional :np_license_number, type: String, desc: 'NP license number.'
          optional :np_license_effective_date, type: String, desc: 'NP license effective date.'
          optional :np_license_expiration_date, type: String, desc: 'NP license expiration date.'
          optional :aprn_not_applicable, type: String, desc: 'Reason APRN/NP not applicable.'
          optional :cnp_explain, type: String, desc: 'Explanation for CNP/NP license.'
          optional :rn_license_number, type: String, desc: 'RN license number.'
          optional :rn_license_effective_date, type: String, desc: 'RN license effective date.'
          optional :rn_license_expiration_date, type: String, desc: 'RN license expiration date.'
          optional :rn_not_applicable, type: String, desc: 'Reason RN not applicable.'
          optional :rn_explain, type: String, desc: 'Explanation for RN license.'
          optional :cds_not_applicable, type: String, desc: 'Reason CDS not applicable.'
          optional :cds_explain, type: String, desc: 'Explanation for CDS.'
          optional :telehealth_license_number, type: String, desc: 'Telehealth license number.'
          optional :board_certified, type: Boolean, desc: 'Is the provider board certified?'
          optional :board_certification_number, type: String, desc: 'Board certification number.'
          optional :board_name, type: String, desc: 'Name of certifying board.'
          optional :board_certificate_number, type: String, desc: 'Board certificate number (duplicate?).'
          optional :board_effective_date, type: Date, desc: 'Board certification effective date.'
          optional :board_recertification_date, type: Date, desc: 'Board recertification date.'
          optional :board_expiration_date, type: Date, desc: 'Board certification expiration date.'
          optional :board_certificate_not_applicable, type: String, desc: 'Reason board cert not applicable.'
          optional :board_cert_explain, type: String, desc: 'Explanation for board cert.'
          optional :board_specialty_type, type: String, desc: 'Type of board specialty.'
          optional :medical_school_name, type: String, desc: 'Name of medical school.'
          optional :medical_school_address, type: String, desc: 'Address of medical school.'
          optional :graduation_date, type: Date, desc: 'Medical school graduation date.'
          optional :school_certificate, type: String, desc: 'Path/ref to school certificate.'
          optional :medical_school, type: String, desc: 'Medical school info (duplicate?).'
          optional :prof_medical_school_name, type: String, desc: 'Prof. medical school name (duplicate?).'
          optional :prof_medical_school_address, type: String, desc: 'Prof. medical school address (duplicate?).'
          optional :prof_medical_school_city, type: String, desc: 'Prof. medical school city.'
          optional :prof_medical_school_state_id, type: Integer, desc: 'Prof. medical school state ID.'
          optional :prof_medical_school_country, type: String, desc: 'Prof. medical school country.'
          optional :prof_medical_school_zipcode, type: String, desc: 'Prof. medical school zipcode.'
          optional :prof_medical_start_date, type: Date, desc: 'Prof. medical school start date.'
          optional :prof_medical_school_degree_awarded, type: String, desc: 'Degree awarded by prof. medical school.'
          optional :liability_issue_date, type: String, desc: 'Liability insurance issue date.'
          optional :liability_expiration_date, type: String, desc: 'Liability insurance expiration date.'
          optional :policy_number, type: String, desc: 'Liability policy number.'
          optional :ins_policy, type: String, desc: 'Insurance policy info/number (duplicate?).'
          optional :ins_policy_effective_date, type: Date, desc: 'Insurance policy effective date.'
          optional :ins_policy_expiration_date, type: Date, desc: 'Insurance policy expiration date.'
          optional :prof_liability_carrier_name, type: String, desc: 'Liability carrier name.'
          optional :prof_liability_self_insured, type: String, desc: 'Is liability self-insured?'
          optional :prof_liability_address, type: String, desc: 'Liability carrier address.'
          optional :prof_liability_city, type: String, desc: 'Liability carrier city.'
          optional :prof_liability_state_id, type: Integer, desc: 'Liability carrier state ID.'
          optional :prof_liability_zipcode, type: String, desc: 'Liability carrier zipcode.'
          optional :prof_liability_orig_effective_date, type: Date, desc: 'Liability original effective date.'
          optional :prof_liability_effective_date, type: Date, desc: 'Liability effective date.'
          optional :prof_liability_expiration_date, type: Date, desc: 'Liability expiration date.'
          optional :prof_liability_coverage_type, type: String, desc: 'Liability coverage type.'
          optional :prof_liability_unlimited_coverage, type: String, desc: 'Is liability coverage unlimited?'
          optional :prof_liability_tail_coverage, type: String, desc: 'Does liability include tail coverage?'
          optional :prof_liability_coverage_amount, type: String, desc: 'Liability coverage amount per occurrence.'
          optional :prof_liability_coverage_amount_aggregate, type: String, desc: 'Liability coverage amount aggregate.'
          optional :prof_liability_policy_number, type: String, desc: 'Liability policy number (duplicate?).'
          optional :dco, type: String, desc: 'DCO information.'
          optional :dco_file, type: String, desc: 'Path/ref to DCO file.'
          optional :provider_hire_date_seeing_patient, type: Date, desc: 'Hire date / date seeing patients.'
          optional :effective_date_seeing_patient, type: Date, desc: 'Effective date seeing patients.'
          optional :employed_by_other, type: String, desc: 'Is provider employed elsewhere?'
          optional :supervised_by_psychologist, type: String, desc: 'Is provider supervised by psychologist?'
          optional :name_admitting_physician, type: String, desc: 'Name of admitting physician.'
          optional :facility_location, type: String, desc: 'Facility location.'
          optional :facility_name, type: String, desc: 'Facility name.'
          optional :admitting_facility_address_line1, type: String, desc: 'Admitting facility address 1.'
          optional :admitting_facility_address_line2, type: String, desc: 'Admitting facility address 2.'
          optional :admitting_facility_city, type: String, desc: 'Admitting facility city.'
          optional :admitting_facility_zip_code, type: String, desc: 'Admitting facility zip code.'
          optional :admitting_facility_arrangments, type: String, desc: 'Admitting facility arrangements.'
          optional :admitting_privileges, type: String, desc: 'Admitting privileges status/info.'
          optional :admitting_facility_state, type: String, desc: 'Admitting facility state.'
          optional :practice_location_name, type: String, desc: 'Practice location name.'
          optional :provider_effective_date, type: Date, desc: 'Provider effective date.'
          optional :dcos, type: String, default: "f", desc: 'DCOs status flag.'
          optional :primary_location, type: String, desc: 'Primary location identifier/name.'
          optional :secondary_enrollment_group_id, type: Integer, desc: 'Secondary enrollment group ID.'
          optional :secondary_primary_location, type: String, desc: 'Secondary primary location identifier.'
          optional :secondary_dcos, type: String, default: "f", desc: 'Secondary DCOs status flag.'
          optional :work_history_not_applicable, type: String, desc: 'Reason work history not applicable.'
          optional :work_history_explain, type: String, desc: 'Explanation for work history.'
          optional :supervising_name_npi, type: String, desc: 'Supervising provider Name/NPI.'
          optional :supervising_name, type: String, desc: 'Supervising provider name.'
          optional :supervising_npi, type: String, desc: 'Supervising provider NPI.'
          optional :revalidation, type: String, desc: 'Revalidation status/info.'
          optional :medicare, type: String, desc: 'Medicare enrollment status/info.'
          optional :medicare_revalidation_date, type: String, desc: 'Medicare revalidation date.'
          optional :medicaid, type: String, desc: 'Medicaid enrollment status/info.'
          optional :medicaid_revalidation_date, type: String, desc: 'Medicaid revalidation date.'
          optional :molina, type: String, desc: 'Molina status/info.'
          optional :mclaren, type: String, desc: 'McLaren status/info.'
          optional :meridian, type: String, desc: 'Meridian status/info.'
          optional :aetna, type: String, desc: 'Aetna status/info.'
          optional :priority_health, type: String, desc: 'Priority Health status/info.'
          optional :amerihealth, type: String, desc: 'AmeriHealth status/info.'
          optional :payer_login, type: String, default: "no", desc: 'Payer login status/info.'
          optional :oig, type: String, desc: 'OIG check status/result.'
          optional :sam, type: String, desc: 'SAM check status/result.'
          optional :roster_result, type: String, desc: 'Roster result info.'
          optional :telehealth_providers, type: String, desc: 'Telehealth provider status/info.'
          optional :encoded_by, type: String, desc: 'Who encoded the record.'
          optional :updated_by, type: String, desc: 'Who last updated the record.'
          optional :new_provider_notification, type: Date, desc: 'Date new provider notification sent.'
          optional :notification_start_date, type: Date, desc: 'Notification start date.'
          optional :welcome_letter_sent, type: Date, desc: 'Date welcome letter sent.'
          optional :notification_enrollment_submit, type: Date, desc: 'Date enrollment notification submitted.'
          optional :notification_services, type: String, desc: 'Notification services info.'
          optional :send_welcome_letter, type: Date, desc: 'Date to send welcome letter.'
          optional :welcome_letter_status, type: Boolean, default: false, desc: 'Welcome letter sent status.'
          optional :welcome_letter_subject, type: String, desc: 'Subject of welcome letter.'
          optional :welcome_letter_message, type: String, desc: 'Message body of welcome letter.'
          optional :welcome_letter_attachments, type: JSON, desc: 'Attachments for welcome letter.'
          optional :check_welcome_letter, type: Boolean, default: false, desc: 'Check status for welcome letter.'
          optional :check_co_caqh, type: Boolean, default: false, desc: 'Check status for CO CAQH.'
          optional :check_mn_caqh_state_release_form, type: Boolean, default: false, desc: 'Check status for MN CAQH State Release.'
          optional :check_mn_caqh_authorization_form, type: Boolean, default: false, desc: 'Check status for MN CAQH Auth Form.'
          optional :check_caqh_standard_authorization, type: Boolean, default: false, desc: 'Check status for CAQH Standard Auth.'
        end
      end

      resource :providers do

        # GET /api/v1/providers
        desc "Return a list of providers"
        params do
          optional :user_id, type: Integer, desc: "Optional User ID to filter providers."
        end
        get do
          providers = if params[:user_id].present?
                        Provider.where(admin_id: params[:user_id])
                      else
                        Provider.all
                      end
          present providers, with: Api::V1::Entities::ProviderEntity
        end

        # POST /api/v1/providers
        desc "Create a provider"
        params do
          use :shared_provider_params
        end
        post do
          provider_params = declared(params, include_missing: false)
          provider = Provider.new(provider_params)

          if provider.save
            present provider, with: Api::V1::Entities::ProviderEntity
          else
            error!({ errors: provider.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/providers/:id
          desc "Return a specific provider"
          get do
            provider = Provider.find(params[:id])
            present provider, with: Api::V1::Entities::ProviderEntity
          end

          # PUT /api/v1/providers/:id
          desc "Update a specific provider"
          params do
            use :shared_provider_params
          end
          put do
            provider = Provider.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if provider.update(update_params)
              present provider, with: Api::V1::Entities::ProviderEntity
            else
              error!({ errors: provider.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/providers/:id
          desc "Delete a specific provider"
          delete do
            provider = Provider.find(params[:id])
            if provider.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider"] }, 500)
            end
          end

        end
      end
    end
  end
end
