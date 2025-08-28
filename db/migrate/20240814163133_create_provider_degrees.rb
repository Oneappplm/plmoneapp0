class CreateProviderDegrees < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_degrees do |t|
      t.integer        :caqh_provider_degree_id
      t.references     :provider_attest
      t.integer        :caqh_provider_attest_id
      t.string         :degree_degree_abbreviation

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_degrees
  end
end
