class CreateProviderAdverseActions < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_adverse_actions, primary_key: [:provider_attest_id,:provider_adverse_action_id] do |t|
      t.integer      :provider_adverse_action_id
      t.references   :provider_attest
      t.datetime     :occurrence_date
      t.text         :occurrence_explanation
      t.datetime     :action_date
      t.text         :action_explanation
      t.string       :current_status
      t.string       :contact_name
      t.string       :department_name
      t.string       :address
      t.string       :city
      t.string       :state
      t.string       :phone_number
      t.string       :postal_code
      t.string       :location
      t.string       :organization_name
      t.datetime     :end_date
      t.text         :disclosure_question_disclosure_summary

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_adverse_actions
  end
end
