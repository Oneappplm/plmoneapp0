class CreateProviderCriminalActions < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_criminal_actions, primary_key: [:provider_attest_id,:provider_criminal_action_id] do |t|
      t.integer        :provider_criminal_action_id
      t.references     :provider_attest
      t.datetime       :incident_date
      t.datetime       :complaint_date
      t.datetime       :resolution_date
      t.string         :resolution_type
      t.boolean        :allegations
      t.text           :incident_details
      t.string         :actions_taken
      t.string         :current_status
      t.string         :privileges_affected
      t.boolean        :sentence_flag
      t.string         :sentence_length
      t.string         :location
      t.text           :disclosure_question_disclosure_summary

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_criminal_actions
  end
end
