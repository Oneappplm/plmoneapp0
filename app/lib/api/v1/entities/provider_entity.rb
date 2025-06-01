module Api
  module V1
    module Entities
      class ProviderEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique database ID of the provider.' }
        expose :admin_id, documentation: { type: 'Integer', desc: 'ID of the associated User.' }
        expose :first_name, documentation: { type: 'String', desc: "Provider's first name." }
        expose :middle_name, documentation: { type: 'String', desc: "Provider's middle name." }
        expose :last_name, documentation: { type: 'String', desc: "Provider's last name." }
        expose :suffix, documentation: { type: 'String', desc: "Provider's suffix." }
        expose :gender, documentation: { type: 'String', desc: "Provider's gender." }
        expose :birth_date, documentation: { type: 'Date', desc: "Provider's date of birth." }
        expose :birth_city, documentation: { type: 'String', desc: 'City of birth.' }
        expose :birth_state, documentation: { type: 'String', desc: 'State of birth.' }
        expose :birth_city_state, documentation: { type: 'String', desc: 'Combined birth city/state.' }
        expose :practitioner_type, documentation: { type: 'String', desc: 'Type of practitioner.' }
        expose :status, documentation: { type: 'String', desc: "Provider's status." }
        expose :terminated, documentation: { type: 'String', desc: 'Termination status/reason.' }
        expose :end_date, documentation: { type: 'String', desc: 'End date associated with provider.' }

        expose :ssn, documentation: { type: 'String', desc: 'Social Security Number.' }
        expose :npi, documentation: { type: 'String', desc: "Provider's National Provider Identifier." }
        expose :caqhid, documentation: { type: 'String', desc: "Provider's CAQH ID." }
        expose :caqh_id, documentation: { type: 'String', desc: "Provider's CAQH ID (duplicate?)." }
        expose :nccpa_number, documentation: { type: 'String', desc: "Provider's NCCPA number." }
        expose :medicare_provider_number, documentation: { type: 'String', desc: 'Medicare provider number.' }
        expose :medicaid_provider_number, documentation: { type: 'String', desc: 'Medicaid provider number.' }
        expose :tricare_provider_number, documentation: { type: 'String', desc: 'Tricare provider number.' }
        expose :taxonomy, documentation: { type: 'String', desc: "Provider's taxonomy code." }
        expose :specialty, documentation: { type: 'String', desc: "Provider's specialty." }

        expose :email_address, documentation: { type: 'String', desc: "Provider's email address." }
        expose :telephone_number, documentation: { type: 'String', desc: "Provider's phone number." }
        expose :ext, documentation: { type: 'String', desc: 'Phone number extension.' }
        expose :address_line_1, documentation: { type: 'String', desc: "Provider's address line 1." }
        expose :address_line_2, documentation: { type: 'String', desc: "Provider's address line 2." }
        expose :city, documentation: { type: 'String', desc: "Provider's city." }
        expose :state_id, documentation: { type: 'Integer', desc: "Provider's state ID." }
        expose :zip_code, documentation: { type: 'String', desc: "Provider's zip code." }

        expose :caqh_attestation_date, documentation: { type: 'Date', desc: 'CAQH Attestation Date.' }
        expose :caqh_pdf, documentation: { type: 'String', desc: 'Path/reference to CAQH PDF.' }
        expose :caqh_pdf_date_received, documentation: { type: 'Date', desc: 'Date CAQH PDF was received.' }
        expose :caqh_username, documentation: { type: 'String', desc: 'CAQH Username.' }
        expose :caqh_password, documentation: { type: 'String', desc: 'CAQH Password.' }
        expose :caqh_state, documentation: { type: 'String', desc: 'CAQH State.' }
        expose :caqh_app, documentation: { type: 'String', desc: 'CAQH App status/reference.' }
        expose :caqh_payor, documentation: { type: 'String', desc: 'CAQH Payor info.' }
        expose :caqh_login, documentation: { type: 'String', desc: 'CAQH Login info/status.' }
        expose :reattestation_date, documentation: { type: 'Date', desc: 'CAQH Reattestation date.' }
        expose :security_question_answer, documentation: { type: 'String', desc: 'CAQH Security answer.' }
        expose :caqh_current_reattestation_date, documentation: { type: 'DateTime', desc: 'CAQH Current Reattestation Date.' }
        expose :caqh_reattest_completed_by, documentation: { type: 'String', desc: 'Who completed CAQH reattestation.' }
        expose :caqh_question, documentation: { type: 'String', desc: 'CAQH Security question.' }
        expose :caqh_answer, documentation: { type: 'String', desc: 'CAQH Security answer (duplicate?).' }
        expose :caqh_notes, documentation: { type: 'String', desc: 'Notes related to CAQH.' }

        expose :license_number, documentation: { type: 'String', desc: 'Primary license number.' }
        expose :license_effective_date, documentation: { type: 'String', desc: 'Primary license effective date.' }
        expose :license_expiration_date, documentation: { type: 'String', desc: 'Primary license expiration date.' }
        expose :state_license, documentation: { type: 'String', desc: 'State license info/number.' }
        expose :state_license_effective_date, documentation: { type: 'Date', desc: 'State license effective date.' }
        expose :state_license_expiration_date, documentation: { type: 'Date', desc: 'State license expiration date.' }
        expose :state_license_effectice_date, documentation: { type: 'Date', desc: 'State license effective date (duplicate?).' }
        expose :license_state_number, documentation: { type: 'String', desc: 'License number for specific state.' }
        expose :license_state_effective_date, documentation: { type: 'String', desc: 'Effective date for specific state license.' }
        expose :license_state_id, documentation: { type: 'String', desc: 'ID of state for specific license.' }
        expose :license_state_expiration_date, documentation: { type: 'String', desc: 'Expiration date for specific state license.' }
        expose :medical_license, documentation: { type: 'String', desc: 'Medical license info/number.' }
        expose :state_not_applicable, documentation: { type: 'String', desc: 'Reason state license not applicable.' }
        expose :license_explain, documentation: { type: 'String', desc: 'Explanation for state license.' }

        expose :dea_number, documentation: { type: 'String', desc: "Provider's DEA number." }
        expose :dea_license_effective_date, documentation: { type: 'Date', desc: 'DEA license effective date.' }
        expose :dea_license_expiration_date, documentation: { type: 'Date', desc: 'DEA license expiration date.' }
        expose :dea_effective_date, documentation: { type: 'String', desc: 'DEA effective date (duplicate?).' }
        expose :dea_expiration_date, documentation: { type: 'String', desc: 'DEA expiration date (duplicate?).' }
        expose :dea_registration_state, documentation: { type: 'String', desc: 'State of DEA registration.' }
        expose :dea_not_applicable, documentation: { type: 'String', desc: 'Reason DEA not applicable.' }
        expose :dea_explain, documentation: { type: 'String', desc: 'Explanation for DEA.' }

        expose :pa_license_effective_date, documentation: { type: 'Date', desc: 'PA license effective date.' }
        expose :pa_license_expiration_date, documentation: { type: 'Date', desc: 'PA license expiration date.' }
        expose :pa_license_number, documentation: { type: 'String', desc: 'PA license number.' }

        expose :np_license_number, documentation: { type: 'String', desc: 'NP license number.' }
        expose :np_license_effective_date, documentation: { type: 'String', desc: 'NP license effective date.' }
        expose :np_license_expiration_date, documentation: { type: 'String', desc: 'NP license expiration date.' }
        expose :aprn_not_applicable, documentation: { type: 'String', desc: 'Reason APRN/NP not applicable.' }
        expose :cnp_explain, documentation: { type: 'String', desc: 'Explanation for CNP/NP license.' }

        expose :rn_license_number, documentation: { type: 'String', desc: 'RN license number.' }
        expose :rn_license_effective_date, documentation: { type: 'String', desc: 'RN license effective date.' }
        expose :rn_license_expiration_date, documentation: { type: 'String', desc: 'RN license expiration date.' }
        expose :rn_not_applicable, documentation: { type: 'String', desc: 'Reason RN not applicable.' }
        expose :rn_explain, documentation: { type: 'String', desc: 'Explanation for RN license.' }

        expose :cds_not_applicable, documentation: { type: 'String', desc: 'Reason CDS not applicable.' }
        expose :cds_explain, documentation: { type: 'String', desc: 'Explanation for CDS.' }

        expose :telehealth_license_number, documentation: { type: 'String', desc: 'Telehealth license number.' }

        expose :board_certified, documentation: { type: 'Boolean', desc: 'Is the provider board certified?' }
        expose :board_certification_number, documentation: { type: 'String', desc: 'Board certification number.' }
        expose :board_name, documentation: { type: 'String', desc: 'Name of certifying board.' }
        expose :board_certificate_number, documentation: { type: 'String', desc: 'Board certificate number (duplicate?).' }
        expose :board_effective_date, documentation: { type: 'Date', desc: 'Board certification effective date.' }
        expose :board_recertification_date, documentation: { type: 'Date', desc: 'Board recertification date.' }
        expose :board_expiration_date, documentation: { type: 'Date', desc: 'Board certification expiration date.' }
        expose :board_certificate_not_applicable, documentation: { type: 'String', desc: 'Reason board cert not applicable.' }
        expose :board_cert_explain, documentation: { type: 'String', desc: 'Explanation for board cert.' }
        expose :board_specialty_type, documentation: { type: 'String', desc: 'Type of board specialty.' }

        expose :medical_school_name, documentation: { type: 'String', desc: 'Name of medical school.' }
        expose :medical_school_address, documentation: { type: 'String', desc: 'Address of medical school.' }
        expose :graduation_date, documentation: { type: 'Date', desc: 'Medical school graduation date.' }
        expose :school_certificate, documentation: { type: 'String', desc: 'Path/ref to school certificate.' }
        expose :medical_school, documentation: { type: 'String', desc: 'Medical school info (duplicate?).' }
        expose :prof_medical_school_name, documentation: { type: 'String', desc: 'Prof. medical school name (duplicate?).' }
        expose :prof_medical_school_address, documentation: { type: 'String', desc: 'Prof. medical school address (duplicate?).' }
        expose :prof_medical_school_city, documentation: { type: 'String', desc: 'Prof. medical school city.' }
        expose :prof_medical_school_state_id, documentation: { type: 'Integer', desc: 'Prof. medical school state ID.' }
        expose :prof_medical_school_country, documentation: { type: 'String', desc: 'Prof. medical school country.' }
        expose :prof_medical_school_zipcode, documentation: { type: 'String', desc: 'Prof. medical school zipcode.' }
        expose :prof_medical_start_date, documentation: { type: 'Date', desc: 'Prof. medical school start date.' }
        expose :prof_medical_school_degree_awarded, documentation: { type: 'String', desc: 'Degree awarded by prof. medical school.' }

        expose :liability_issue_date, documentation: { type: 'String', desc: 'Liability insurance issue date.' }
        expose :liability_expiration_date, documentation: { type: 'String', desc: 'Liability insurance expiration date.' }
        expose :policy_number, documentation: { type: 'String', desc: 'Liability policy number.' }
        expose :ins_policy, documentation: { type: 'String', desc: 'Insurance policy info/number (duplicate?).' }
        expose :ins_policy_effective_date, documentation: { type: 'Date', desc: 'Insurance policy effective date.' }
        expose :ins_policy_expiration_date, documentation: { type: 'Date', desc: 'Insurance policy expiration date.' }
        expose :prof_liability_carrier_name, documentation: { type: 'String', desc: 'Liability carrier name.' }
        expose :prof_liability_self_insured, documentation: { type: 'String', desc: 'Is liability self-insured?' }
        expose :prof_liability_address, documentation: { type: 'String', desc: 'Liability carrier address.' }
        expose :prof_liability_city, documentation: { type: 'String', desc: 'Liability carrier city.' }
        expose :prof_liability_state_id, documentation: { type: 'Integer', desc: 'Liability carrier state ID.' }
        expose :prof_liability_zipcode, documentation: { type: 'String', desc: 'Liability carrier zipcode.' }
        expose :prof_liability_orig_effective_date, documentation: { type: 'Date', desc: 'Liability original effective date.' }
        expose :prof_liability_effective_date, documentation: { type: 'Date', desc: 'Liability effective date.' }
        expose :prof_liability_expiration_date, documentation: { type: 'Date', desc: 'Liability expiration date.' }
        expose :prof_liability_coverage_type, documentation: { type: 'String', desc: 'Liability coverage type.' }
        expose :prof_liability_unlimited_coverage, documentation: { type: 'String', desc: 'Is liability coverage unlimited?' }
        expose :prof_liability_tail_coverage, documentation: { type: 'String', desc: 'Does liability include tail coverage?' }
        expose :prof_liability_coverage_amount, documentation: { type: 'String', desc: 'Liability coverage amount per occurrence.' }
        expose :prof_liability_coverage_amount_aggregate, documentation: { type: 'String', desc: 'Liability coverage amount aggregate.' }
        expose :prof_liability_policy_number, documentation: { type: 'String', desc: 'Liability policy number (duplicate?).' }

        expose :dco, documentation: { type: 'String', desc: 'DCO information.' }
        expose :dco_file, documentation: { type: 'String', desc: 'Path/ref to DCO file.' }
        expose :provider_hire_date_seeing_patient, documentation: { type: 'Date', desc: 'Hire date / date seeing patients.' }
        expose :effective_date_seeing_patient, documentation: { type: 'Date', desc: 'Effective date seeing patients.' }
        expose :employed_by_other, documentation: { type: 'String', desc: 'Is provider employed elsewhere?' }
        expose :supervised_by_psychologist, documentation: { type: 'String', desc: 'Is provider supervised by psychologist?' }
        expose :name_admitting_physician, documentation: { type: 'String', desc: 'Name of admitting physician.' }
        expose :facility_location, documentation: { type: 'String', desc: 'Facility location.' }
        expose :facility_name, documentation: { type: 'String', desc: 'Facility name.' }
        expose :admitting_facility_address_line1, documentation: { type: 'String', desc: 'Admitting facility address 1.' }
        expose :admitting_facility_address_line2, documentation: { type: 'String', desc: 'Admitting facility address 2.' }
        expose :admitting_facility_city, documentation: { type: 'String', desc: 'Admitting facility city.' }
        expose :admitting_facility_zip_code, documentation: { type: 'String', desc: 'Admitting facility zip code.' }
        expose :admitting_facility_arrangments, documentation: { type: 'String', desc: 'Admitting facility arrangements.' }
        expose :admitting_privileges, documentation: { type: 'String', desc: 'Admitting privileges status/info.' }
        expose :admitting_facility_state, documentation: { type: 'String', desc: 'Admitting facility state.' }
        expose :practice_location_name, documentation: { type: 'String', desc: 'Practice location name.' }
        expose :provider_effective_date, documentation: { type: 'Date', desc: 'Provider effective date.' }
        expose :dcos, documentation: { type: 'String', desc: "DCOs status flag." }
        expose :primary_location, documentation: { type: 'String', desc: 'Primary location identifier/name.' }
        expose :secondary_enrollment_group_id, documentation: { type: 'Integer', desc: 'Secondary enrollment group ID.' }
        expose :secondary_primary_location, documentation: { type: 'String', desc: 'Secondary primary location identifier.' }
        expose :secondary_dcos, documentation: { type: 'String', desc: "Secondary DCOs status flag." }
        expose :work_history_not_applicable, documentation: { type: 'String', desc: 'Reason work history not applicable.' }
        expose :work_history_explain, documentation: { type: 'String', desc: 'Explanation for work history.' }
        expose :supervising_name_npi, documentation: { type: 'String', desc: 'Supervising provider Name/NPI.' }
        expose :supervising_name, documentation: { type: 'String', desc: 'Supervising provider name.' }
        expose :supervising_npi, documentation: { type: 'String', desc: 'Supervising provider NPI.' }

        expose :revalidation, documentation: { type: 'String', desc: 'Revalidation status/info.' }
        expose :medicare, documentation: { type: 'String', desc: 'Medicare enrollment status/info.' }
        expose :medicare_revalidation_date, documentation: { type: 'String', desc: 'Medicare revalidation date.' }
        expose :medicaid, documentation: { type: 'String', desc: 'Medicaid enrollment status/info.' }
        expose :medicaid_revalidation_date, documentation: { type: 'String', desc: 'Medicaid revalidation date.' }
        expose :molina, documentation: { type: 'String', desc: 'Molina status/info.' }
        expose :mclaren, documentation: { type: 'String', desc: 'McLaren status/info.' }
        expose :meridian, documentation: { type: 'String', desc: 'Meridian status/info.' }
        expose :aetna, documentation: { type: 'String', desc: 'Aetna status/info.' }
        expose :priority_health, documentation: { type: 'String', desc: 'Priority Health status/info.' }
        expose :amerihealth, documentation: { type: 'String', desc: 'AmeriHealth status/info.' }
        expose :payer_login, documentation: { type: 'String', desc: 'Payer login status/info.' }

        expose :oig, documentation: { type: 'String', desc: 'OIG check status/result.' }
        expose :sam, documentation: { type: 'String', desc: 'SAM check status/result.' }

        expose :roster_result, documentation: { type: 'String', desc: 'Roster result info.' }
        expose :telehealth_providers, documentation: { type: 'String', desc: 'Telehealth provider status/info.' }
        expose :encoded_by, documentation: { type: 'String', desc: 'Who encoded the record.' }
        expose :updated_by, documentation: { type: 'String', desc: 'Who last updated the record.' }
        expose :new_provider_notification, documentation: { type: 'Date', desc: 'Date new provider notification sent.' }
        expose :notification_start_date, documentation: { type: 'Date', desc: 'Notification start date.' }
        expose :welcome_letter_sent, documentation: { type: 'Date', desc: 'Date welcome letter sent.' }
        expose :notification_enrollment_submit, documentation: { type: 'Date', desc: 'Date enrollment notification submitted.' }
        expose :notification_services, documentation: { type: 'String', desc: 'Notification services info.' }
        expose :send_welcome_letter, documentation: { type: 'Date', desc: 'Date to send welcome letter.' }
        expose :welcome_letter_status, documentation: { type: 'Boolean', desc: 'Welcome letter sent status.' }
        expose :welcome_letter_subject, documentation: { type: 'String', desc: 'Subject of welcome letter.' }
        expose :welcome_letter_message, documentation: { type: 'String', desc: 'Message body of welcome letter.' }
        expose :welcome_letter_attachments, documentation: { type: 'JSON', desc: 'Attachments for welcome letter.' }
        expose :check_welcome_letter, documentation: { type: 'Boolean', desc: 'Check status for welcome letter.' }
        expose :check_co_caqh, documentation: { type: 'Boolean', desc: 'Check status for CO CAQH.' }
        expose :check_mn_caqh_state_release_form, documentation: { type: 'Boolean', desc: 'Check status for MN CAQH State Release.' }
        expose :check_mn_caqh_authorization_form, documentation: { type: 'Boolean', desc: 'Check status for MN CAQH Auth Form.' }
        expose :check_caqh_standard_authorization, documentation: { type: 'Boolean', desc: 'Check status for CAQH Standard Auth.' }

        expose :state_license_copy_file, documentation: { type: 'String', desc: 'Path/ref to state license copy file.' }
        expose :dea_copy_file, documentation: { type: 'String', desc: 'Path/ref to DEA copy file.' }
        expose :w9_form_file, documentation: { type: 'String', desc: 'Path/ref to W9 form file.' }
        expose :certificate_insurance_file, documentation: { type: 'String', desc: 'Path/ref to certificate of insurance file.' }
        expose :drivers_license_file, documentation: { type: 'String', desc: 'Path/ref to drivers license file.' }
        expose :board_certification_file, documentation: { type: 'String', desc: 'Path/ref to board certification file.' }
        expose :caqh_app_copy_file, documentation: { type: 'String', desc: 'Path/ref to CAQH app copy file.' }
        expose :cv_file, documentation: { type: 'String', desc: 'Path/ref to CV file.' }
        expose :telehealth_license_copy_file, documentation: { type: 'String', desc: 'Path/ref to telehealth license copy file.' }

        expose :state_license_copies, documentation: { type: 'JSON', desc: 'JSON data for state license copies.' }
        expose :dea_copies, documentation: { type: 'JSON', desc: 'JSON data for DEA copies.' }
        expose :w9_form_copies, documentation: { type: 'JSON', desc: 'JSON data for W9 form copies.' }
        expose :certificate_insurance_copies, documentation: { type: 'JSON', desc: 'JSON data for certificate of insurance copies.' }
        expose :driver_license_copies, documentation: { type: 'JSON', desc: 'JSON data for driver license copies.' }
        expose :board_certification_copies, documentation: { type: 'JSON', desc: 'JSON data for board certification copies.' }
        expose :caqh_app_copies, documentation: { type: 'JSON', desc: 'JSON data for CAQH app copies.' }
        expose :cv_copies, documentation: { type: 'JSON', desc: 'JSON data for CV copies.' }
        expose :telehealth_license_copies, documentation: { type: 'JSON', desc: 'JSON data for telehealth license copies.' }

        expose :api_token, documentation: { type: 'String', desc: 'API Token for the provider.' }

        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the provider was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the provider was last updated.' }
      end
    end
  end
end
