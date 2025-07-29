class CreateProviderCds < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_cds do |t|
      t.integer      :caqh_provider_cdsid
      t.references   :provider_attest
      t.integer      :caqh_provider_attest_id
      t.string       :cds_number
      t.string       :state
      t.datetime     :expiration_date
      t.datetime     :issue_date
      t.boolean      :currently_practicing_flag
      t.text         :cds_limitation_explanation
      t.string       :cds_status

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_cds
  end
end
