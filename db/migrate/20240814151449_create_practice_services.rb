class CreatePracticeServices < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_services do |t|
      t.integer       :caqh_provider_practice_service_id
      t.references    :provider_attest
      t.integer       :caqh_provider_attest_id
      t.boolean       :service_provided_flag
      t.string        :anesthesia_category
      t.string        :anesthesia_first_name
      t.string        :anesthesia_last_name
      t.text          :other_service_description
      t.string        :xray_certification_type
      t.string        :laboratory_certification_program
      t.datetime      :new_patient_wait_time
      t.datetime      :existing_patient_wait_time
      t.datetime      :call_response_time
      t.text          :laboratory_services_description
      t.boolean       :clia_waiver_flag
      t.datetime      :clia_waiver_expiration_date
      t.boolean       :clia_certification_flag
      t.string        :clia_number
      t.string        :clia_waiver_number
      t.datetime      :clia_expiration_date
      t.string        :tax_id
      t.string        :billing_name
      t.text          :omitted_service_description
      t.string        :laboratory_name
      t.string        :service_service_name
      t.references    :practice_information
      t.integer       :caqh_provider_practice_id
      t.timestamps
    end
  end

  def self.down
    drop_table :practice_services
  end
end
