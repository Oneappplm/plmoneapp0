class CreateProviderDisclosures < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_disclosures do |t|
      t.integer        :caqh_provider_disclosure_id
      t.references     :provider_attest
      t.integer        :caqh_provider_attest_id
      t.boolean        :disclosure_answer_flag
      t.datetime       :disclosure_date
      t.text           :disclosure_explanation
      t.text           :disclosure_question_disclosure_summary

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_disclosures
  end
end
