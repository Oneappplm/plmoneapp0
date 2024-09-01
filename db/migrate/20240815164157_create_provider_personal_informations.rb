class CreateProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_personal_informations, primary_key: [:provider_attest_id,:provider_id] do |t|
      t.integer          :provider_id
      t.references       :provider_attest
      t.string           :last_name
      t.string           :first_name
      t.string           :middle_name
      t.string           :suffix
      t.string           :primary_practice_state
      t.boolean          :other_name_flag
      t.datetime         :birth_date
      t.boolean          :us_eligible_flag
      t.string           :ssn
      t.string           :nid
      t.string           :dea_flag
      t.string           :cds_flag
      t.string           :upin
      t.string           :upin_flag
      t.string           :npi_flag
      t.string           :npi
      t.boolean          :medicare_provider_flag
      t.boolean          :medicaid_provider_flag
      t.boolean          :other_graduate_education_flag
      t.boolean          :fellowship_training_flag
      t.boolean          :teaching_appointment_flag
      t.boolean          :secondary_specialty_flag
      t.boolean          :other_specialty_flag
      t.boolean          :hospital_privilege_flag
      t.string           :hospital_admitting_arrangements
      t.boolean          :work_history_gap_flag
      t.boolean          :active_military_flag
      t.string           :citizenship_status
      t.string           :visa_number
      t.string           :federal_employee_id
      t.boolean          :no_malpractice_claims_flag
      t.string           :application_type
      t.boolean          :ecfmg_flag
      t.string           :ecfmg_number
      t.datetime         :ecfmg_issue_date
      t.boolean          :hospital_based_flag
      t.string           :email_address
      t.string           :visa_type
      t.string           :visa_status
      t.string           :birth_city
      t.string           :birth_state
      t.string           :tax_id
      t.string           :spouse_last_name
      t.string           :spouse_first_name
      t.string           :other_correspondence_address
      t.string           :emergency_contact_last_name
      t.string           :emergency_contact_first_name
      t.string           :emergency_contact_middle_name
      t.string           :emergency_contact_phone
      t.string           :pager_beeper_number
      t.string           :answering_service_phone_number
      t.string           :cell_phone_number
      t.boolean          :pager_beeper_digital_flag
      t.datetime         :visa_expiration_date
      t.string           :ethnicity_description
      t.datetime         :visa_issue_date
      t.datetime         :ecfmg_expiration_date
      t.string           :work_permit_status
      t.string           :spouse_middle_name
      t.datetime         :state_residence_date
      t.string           :citizenship_country_country_name
      t.text             :marital_status_marital_status_description
      t.text             :gender_gender_description
      t.string           :birth_country_country_name
      t.text             :correspondence_address_type_correspondence_address_type_description
      t.string           :provider_type_provider_type_abbreviation
      t.text             :graduate_type_graduate_type_description
      t.string           :nid_country_country_name
      t.datetime         :attest_date
      t.string           :plan_provider_id
      t.datetime         :last_recredential_date
      t.datetime         :next_recredential_date

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_personal_informations
  end
end
