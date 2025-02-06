class CreateProviderAttests < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_attests, id: false do |t|
      t.primary_key :provider_attest_id
      t.timestamps
    end
  end
  def self.down
    drop_table :provider_attests
  end
end