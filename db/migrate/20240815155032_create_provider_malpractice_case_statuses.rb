class CreateProviderMalpracticeCaseStatuses < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_malpractice_case_statuses do |t|
      t.integer         :caqh_provider_malpractice_claim_status_id
      t.references      :provider_attest
      t.integer         :caqh_provider_attest_id
      t.string          :claim_status
      t.float           :settlement_amount
      t.float           :settlement_amount_paid
      t.string          :defense_attorney
      t.datetime        :status_date
      t.float           :sought_amount
      t.float           :total_amount
      t.string          :defense_attorney_phone_number
      t.string          :defense_attorney_address
      t.string          :defense_attorney_address2
      t.string          :defense_attorney_city
      t.string          :defense_attorney_state
      t.string          :defense_attorney_postal_code
      t.string          :defense_attorney_province
      t.string          :defense_attorney_county
      t.string          :defense_attorney_country_country_name
      t.references      :provider_malpractice_history, index:false
      t.integer         :caqh_provider_malpractice_id
      t.timestamps
    end

    add_index  :provider_malpractice_case_statuses, :provider_malpractice_history_id, :name => 'pmcs_pm_id'
  end

  def self.down
    drop_table :provider_malpractice_case_statuses
  end
end
