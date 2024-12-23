class AddColumnsToPracticeInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :practice_informations, :country, :string
    add_column :practice_informations, :office_manager, :string
    add_column :practice_informations, :manager_phone_number, :string
    add_column :practice_informations, :manager_fax_number, :string
    add_column :practice_informations, :back_office_phone_number, :string
    add_column :practice_informations, :type_of_practice, :string
    add_column :practice_informations, :mail_stop, :string
    add_column :practice_informations, :hospital_based_department_name, :string
    add_column :practice_informations, :practice_type, :string
    add_column :practice_informations, :group_name, :string
    add_column :practice_informations, :group_number_with_tax_id, :string
    add_column :practice_informations, :name_affiliated_with_tax_id, :string
    add_column :practice_informations, :federal_tax_id, :string
    add_column :practice_informations, :number_of_patients_weekly, :string
    add_column :practice_informations, :total_number_of_patients, :string
    add_column :practice_informations, :total_medicare_patients, :string
    add_column :practice_informations, :total_medical_medicaid_patients, :string
    add_column :practice_informations, :is_ccs, :boolean, default: false
    add_column :practice_informations, :is_chdp, :boolean, default: false
    add_column :practice_informations, :any_allied_health_practitioner, :boolean, default: false
    add_column :practice_informations, :physician_to_nurse_ratio, :integer
    add_column :practice_informations, :physician_to_midwife_ratio, :integer
    add_column :practice_informations, :physician_to_assistant_ratio, :integer
    add_column :practice_informations, :is_employing_any_personal_practitioner, :boolean, default: false
    add_column :practice_informations, :is_licensed_member_in_practice, :boolean, default: false
    add_column :practice_informations, :is_staff_speak_any_foreign_language, :boolean, default: false
    add_column :practice_informations, :radiology_services, :boolean, default: false
    add_column :practice_informations, :allergy_injections, :boolean, default: false
    add_column :practice_informations, :age_approriate_immunizations, :boolean, default: false
    add_column :practice_informations, :osteopathic_manipulations, :boolean, default: false
    add_column :practice_informations, :ekg, :boolean, default: false
    add_column :practice_informations, :allergy_skin_tests, :boolean, default: false
    add_column :practice_informations, :flexible_sigmoidoscopy, :boolean, default: false
    add_column :practice_informations, :iv_hydration_treatments, :boolean, default: false
    add_column :practice_informations, :care_of_minor_lacerations, :boolean, default: false
    add_column :practice_informations, :routine_office_gynecology, :boolean, default: false
    add_column :practice_informations, :tympanometry_audiometry_tests, :boolean, default: false
    add_column :practice_informations, :cardiac_stress_tests, :boolean, default: false
    add_column :practice_informations, :pulmonary_function_tests, :boolean, default: false
    add_column :practice_informations, :drawing_blood, :boolean, default: false
    add_column :practice_informations, :asthma_treatmeant, :boolean, default: false
    add_column :practice_informations, :physical_therapies, :boolean, default: false
    add_column :practice_informations, :other_surgical_services, :string
    add_column :practice_informations, :clinical_services_performed_not_typically_associated, :string
    add_column :practice_informations, :clinical_services_not_performed_typically_associated, :string
    add_column :practice_informations, :has_practice_limit_age, :boolean, default: false
    add_column :practice_informations, :practice_limit_age_from, :string
    add_column :practice_informations, :practice_limit_age_to, :string
    add_column :practice_informations, :has_limited_gender, :boolean, default: false
    add_column :practice_informations, :limited_gender, :string
    add_column :practice_informations, :other_limitations, :string
    add_column :practice_informations, :computer_office, :string
    add_column :practice_informations, :computer_office_has_other, :boolean, default: false
    add_column :practice_informations, :computer_office_other, :string
    add_column :practice_informations, :operating_system, :string
    add_column :practice_informations, :has_os_office_other, :boolean, default: false
    add_column :practice_informations, :os_office_other, :string
    add_column :practice_informations, :has_computer_has_internet_access, :boolean, default: false
    add_column :practice_informations, :does_participate_edi, :boolean, default: false
    add_column :practice_informations, :edi_network, :string
    add_column :practice_informations, :has_practice_management_software, :boolean, default: false
    add_column :practice_informations, :practice_management_software, :string
    add_column :practice_informations, :does_perform_surgery, :boolean, default: false
    add_column :practice_informations, :anesthesia_local, :boolean, default: false
    add_column :practice_informations, :anesthesia_regional, :boolean, default: false
    add_column :practice_informations, :anesthesia_conscious_sedation, :boolean, default: false
    add_column :practice_informations, :anesthesia_general, :boolean, default: false
    add_column :practice_informations, :anesthesia_other, :boolean, default: false
    add_column :practice_informations, :anesthesia_other_value, :string
    add_column :practice_informations, :anesthesia_none, :boolean, default: false
    add_column :practice_informations, :ambulatory_surgery_facilities, :boolean, default: false
    add_column :practice_informations, :health_surgery_licensure, :boolean, default: false
    add_column :practice_informations, :ambulatory_health_care, :boolean, default: false
    add_column :practice_informations, :medicare_certification, :boolean, default: false
    add_column :practice_informations, :medical_quality_commission, :boolean, default: false
    add_column :practice_informations, :other_certification, :boolean, default: false
    add_column :practice_informations, :other_certification_explanation, :text
    add_column :practice_informations, :certification_none, :boolean, default: false
    add_column :practice_informations, :is_laboratory_services, :boolean, default: false
    add_column :practice_informations, :billing_name, :string
    add_column :practice_informations, :tax_id, :string
    add_column :practice_informations, :type_of_service, :string
    add_column :practice_informations, :clia_waiver, :boolean, default: false
    add_column :practice_informations, :clia_certificate, :boolean, default: false
    add_column :practice_informations, :clia_certificate_number, :integer
    add_column :practice_informations, :clia_certificate_expiration_date, :date
    add_column :practice_informations, :clia_certification_of_participation, :string
    add_column :practice_informations, :other_clia, :string
    add_column :practice_informations, :xray_certification_type, :string
    add_column :practice_informations, :coverage_24_hour, :boolean, default: false
    add_column :practice_informations, :answering_service, :boolean, default: false
    add_column :practice_informations, :voice_mail_with_instruction, :boolean, default: false
    add_column :practice_informations, :voice_mail_with_other_instruction, :boolean, default: false
    add_column :practice_informations, :answering_service_company, :string
    add_column :practice_informations, :answering_service_fax_number, :string 
    add_column :practice_informations, :answering_service_mail_address, :string
    add_column :practice_informations, :answering_service_mail_stop, :string
    add_column :practice_informations, :answering_service_address2, :string
    add_column :practice_informations, :answering_service_city, :string
    add_column :practice_informations, :answering_service_country, :string
    add_column :practice_informations, :answering_service_state, :string
    add_column :practice_informations, :answering_service_zipcode, :string
    add_column :practice_informations, :any_cover_practitioner, :boolean, default: false
    add_column :practice_informations, :ada_accessibility, :boolean, default: false
    add_column :practice_informations, :handicapped_building, :boolean, default: false
    add_column :practice_informations, :handicapped_parking, :boolean, default: false
    add_column :practice_informations, :handicapped_restroom, :boolean, default: false
    add_column :practice_informations, :handicapped_other, :boolean, default: false
    add_column :practice_informations, :handicapped_other_explaination, :string
    add_column :practice_informations, :disabled_telephony, :boolean, default: false
    add_column :practice_informations, :american_sign_language, :boolean, default: false
    add_column :practice_informations, :disabled_impairment_services, :boolean, default: false
    add_column :practice_informations, :disabled_other, :boolean, default: false
    add_column :practice_informations, :disabled_other_explaination, :string
    add_column :practice_informations, :other_communication_system, :boolean, default: false
    add_column :practice_informations, :public_transportation, :boolean, default: false
    add_column :practice_informations, :public_bus, :boolean, default: false
    add_column :practice_informations, :public_subway, :boolean, default: false
    add_column :practice_informations, :public_regional_train, :boolean, default: false
    add_column :practice_informations, :public_other_transportation, :boolean, default: false
    add_column :practice_informations, :public_other_transportation_explaination, :string
    add_column :practice_informations, :is_provide_child_care_service, :boolean, default: false
    add_column :practice_informations, :is_tdd, :boolean, default: false
    add_column :practice_informations, :is_epsdt_certified, :boolean, default: false
    add_column :practice_informations, :epsdt_certificate_number, :integer
    add_column :practice_informations, :is_directory_location_listed, :boolean, default: false
    add_column :practice_informations, :is_minority_business_enterprise, :boolean, default: false
    add_column :practice_informations, :group_npi, :integer
    add_column :practice_informations, :is_primary_location, :boolean, default: false
    add_column :practice_informations, :any_comments, :text
    add_column :practice_informations, :mon_time_from, :time
    add_column :practice_informations, :mon_time_to, :time
    add_column :practice_informations, :mon_closed, :boolean, default: false
    add_column :practice_informations, :tue_time_from, :time
    add_column :practice_informations, :tue_time_to, :time
    add_column :practice_informations, :tue_closed, :boolean, default: false
    add_column :practice_informations, :wed_time_from, :time
    add_column :practice_informations, :wed_time_to, :time
    add_column :practice_informations, :wed_closed, :boolean, default: false
    add_column :practice_informations, :thu_time_from, :time
    add_column :practice_informations, :thu_time_to, :time
    add_column :practice_informations, :thu_closed, :boolean, default: false
    add_column :practice_informations, :fri_time_from, :time
    add_column :practice_informations, :fri_time_to, :time
    add_column :practice_informations, :fri_closed, :boolean, default: false
    add_column :practice_informations, :sat_time_from, :time
    add_column :practice_informations, :sat_time_to, :time
    add_column :practice_informations, :sat_closed, :boolean, default: false
    add_column :practice_informations, :sun_time_from, :time
    add_column :practice_informations, :sun_time_to, :time
    add_column :practice_informations, :sun_closed, :boolean, default: false
    add_column :practice_informations, :holiday_time_from, :time
    add_column :practice_informations, :holiday_time_to, :time
    add_column :practice_informations, :holiday_closed, :boolean, default: false
  end
end
