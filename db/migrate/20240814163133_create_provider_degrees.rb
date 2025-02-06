class CreateProviderDegrees < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_degrees, primary_key: [:provider_attest_id,:provider_degree_id] do |t|
      t.integer        :provider_degree_id
      t.references     :provider_attest
      t.string         :degree_degree_abbreviation

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_degrees
  end
end
