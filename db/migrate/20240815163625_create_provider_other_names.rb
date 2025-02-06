class CreateProviderOtherNames < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_other_names, primary_key: [:provider_attest_id,:provider_other_name_id] do |t|
      t.integer        :provider_other_name_id
      t.references     :provider_attest
      t.string         :last_name
      t.string         :first_name
      t.string         :middle_name
      t.string         :suffix
      t.datetime       :start_date
      t.datetime       :end_date
      t.text           :other_name_explanation

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_other_names
  end
end
