class CreateProviderDisclosures < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_disclosures, primary_key: [:provider_attest_id,:provider_disclosure_id] do |t|
      t.integer        :provider_disclosure_id
      t.references     :provider_attest
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
