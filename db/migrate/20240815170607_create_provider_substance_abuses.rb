class CreateProviderSubstanceAbuses < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_substance_abuses, primary_key: [:provider_attest_id,:provider_substance_abuse_id] do |t|
      t.integer        :provider_substance_abuse_id
      t.references     :provider_attest
      t.text           :substance_description
      t.string         :current_ability
      t.string         :monitor_entity_name
      t.string         :address
      t.string         :city
      t.string         :state
      t.string         :postal_code
      t.string         :current_status
      t.datetime       :abstinent_date
      t.string         :provider_name
      t.string         :provider_address
      t.string         :provider_city
      t.string         :provider_telephone
      t.string         :provider_state
      t.string         :monitor_type
      t.text           :disclosure_question_disclosure_summary

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_substance_abuses
  end
end
