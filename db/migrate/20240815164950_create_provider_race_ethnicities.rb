class CreateProviderRaceEthnicities < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_race_ethnicities, primary_key: [:provider_attest_id,:provider_race_ethnicity_id] do |t|
      t.integer       :provider_race_ethnicity_id
      t.references     :provider_attest
      t.string         :race_ethnicity_level_1
      t.string         :race_ethnicity_level_2
      t.string         :race_ethnicity_level_3

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_race_ethnicities
  end
end
