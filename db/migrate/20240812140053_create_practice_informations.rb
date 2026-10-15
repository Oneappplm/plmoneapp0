class CreatePracticeInformations < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_informations do |t|
      t.integer        :caqh_provider_practice_id
      t.references     :provider_attest
      t.integer        :caqh_provider_attest_id
      t.string         :practice_name
      t.string         :address
      t.string         :address2
      t.string         :city
      t.string         :state
      t.string         :zip
      t.string         :ext_zip
      t.string         :county
      t.string         :phone_number
      t.string         :after_hours_phone_number
      t.string         :fax_number
      t.string         :email_address
      t.boolean        :correspondence_flag
      t.boolean        :partners_flag
      t.boolean        :other_associates_flag
      t.boolean        :currently_practicing_flag
      t.datetime       :start_date
      t.boolean        :coverage24x7_flag
      t.boolean        :practice_limitation_flag
      t.boolean        :ada_approved_flag
      t.boolean        :minority_business_flag
      t.boolean        :interpreter_available_flag
      t.string         :medicare_number
      t.string         :medicaid_number
      t.boolean        :epsdt_certified_flag
      t.string         :epsdt_number
      t.string         :practice_organization_type
      t.string         :phone_number2
      t.string         :patient_appointment_phone_number
      t.string         :answering_service_phone_number
      t.string         :pager_beeper_number
      t.boolean        :list_in_directory_flag
      t.string         :w9_practice_name
      t.boolean        :in_practice_flag
      t.text           :practice_intention_explanation
      t.string         :emergency_phone_number
      t.text           :practice_description
      t.string         :patients_enrolled
      t.string         :patient_visits
      t.string         :appointments_per_hour
      t.string         :average_waiting_time
      t.string         :call_response_time
      t.boolean        :electronic_billing_flag
      t.string         :bwc_number
      t.string         :workers_compensation_risk_number
      t.text           :ownership_description
      t.string         :emergency_procedure
      t.string         :npi
      t.text           :practice_type_description
      t.text           :service_type_description
      t.string         :department_name
      t.string         :cell_phone_number
      t.string         :pager_beeper_number2
      t.datetime       :end_date
      t.string         :phone_extension
      t.string         :patient_appointment_phone_extension
      t.string         :answering_service_phone_extension
      t.string         :correspondence_method
      t.text           :address_type_address_type_description

      t.timestamps
    end
  end

  def self.down
    drop_table :practice_informations
  end
end
