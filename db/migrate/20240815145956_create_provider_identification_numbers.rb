class CreateProviderIdentificationNumbers < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_identification_numbers, primary_key: [:provider_attest_id,:provider_identifier_id] do |t|
      t.integer        :provider_identifier_id
      t.references     :provider_attest
      t.string         :identifier_value
      t.string         :identifier_status
      t.boolean        :identifier_flag
      t.string         :state
      t.datetime       :issue_date
      t.datetime       :expiration_date
      t.string         :sponsor
      t.string         :country_country_name
      t.text           :identifier_type_identifier_type_description
      t.timestamps
    end
  end

  def self.down
    drop_table :provider_identification_numbers
  end
end
