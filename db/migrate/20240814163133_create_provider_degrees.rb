class CreateProviderDegrees < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_degrees, id: false do |t|
      t.primary_key    :provider_degree_id
      t.references     :provider_attest
      t.string         :degree_degree_abbreviation

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_degrees
  end
end
