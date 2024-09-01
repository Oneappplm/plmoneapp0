class CreateProviderTimeGaps < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_time_gaps, primary_key: [:provider_attest_id,:provider_time_gap_id] do |t|
      t.integer        :provider_time_gap_id
      t.references     :provider_attest
      t.datetime       :start_date
      t.datetime       :end_date
      t.text           :gap_explanation
      t.text           :gap_description

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_time_gaps
  end
end
