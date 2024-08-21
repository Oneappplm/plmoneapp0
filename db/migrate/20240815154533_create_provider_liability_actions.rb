class CreateProviderLiabilityActions < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_liability_actions, id: false do |t|
      t.primary_key  :provider_liability_action_id
      t.references   :provider_attest
      t.string       :insurance_history
      t.string       :carrier_name
      t.string       :policy_number
      t.string       :address
      t.string       :city
      t.string       :state
      t.string       :postal_code
      t.string       :phone_number
      t.datetime     :start_date
      t.datetime     :end_date
      t.text         :circumstances_description
      t.text         :disclosure_question_disclosure_summary

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_liability_actions
  end
end
