class CreateProviderMalpracticeHistories < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_malpractice_histories do |t|
      t.integer         :caqh_provider_malpractice_id
      t.references      :provider_attest
      t.integer         :caqh_provider_attest_id
      t.string          :insurance_carrier_name
      t.datetime        :occurrence_date
      t.string          :claim_date
      t.string          :address
      t.string          :address2
      t.string          :city
      t.string          :state
      t.string          :zip
      t.string          :phone_number
      t.string          :policy_number
      t.text            :allegation_description
      t.boolean         :primary_defendant_flag
      t.string          :number_other_codefendant
      t.string          :case_involvement
      t.text            :patient_injury_description
      t.boolean         :npdb_case_flag
      t.boolean         :court_suit_filed_flag
      t.datetime        :court_date
      t.string          :case_number
      t.string          :case_state
      t.string          :case_county
      t.string          :district
      t.string          :federal_case_number
      t.string          :defendant_name
      t.string          :plaintiff_name
      t.string          :plaintiff_age
      t.string          :other_defendant_names
      t.string          :patient_outcome
      t.boolean         :still_pending_flag
      t.boolean         :still_pending_date
      t.boolean         :trial_date_set_flag
      t.string          :province
      t.string          :provider_status
      t.string          :provider_role
      t.datetime        :case_closed_date
      t.string          :patient_name
      t.string          :patient_age
      t.string          :case_city
      t.string          :incident_location
      t.boolean         :carrier_flag
      t.string          :contact_name
      t.string          :claim_number
      t.text            :other_case_description
      t.string          :court
      t.string          :court_address
      t.boolean         :legal_counsel_flag
      t.boolean         :patient_died_flag
      t.string          :court_address2
      t.string          :court_city
      t.string          :license_number
      t.string          :court_state
      t.string          :court_province
      t.string          :court_zip
      t.string          :country_country_name
      t.text            :disclosure_question_disclosure_summary
      t.text            :patient_gender_gender_description
      t.string          :court_country_country_name
      t.string          :malpractice_resolution_malpractice_resolution_method

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_malpractice_histories
  end
end
