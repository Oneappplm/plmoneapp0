class CreateProviderOtherInterests < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_other_interests, id: false do |t|
      t.primary_key    :provider_other_interest_id
      t.references     :provider_attest
      t.text           :other_interest_description

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_other_interests
  end
end
