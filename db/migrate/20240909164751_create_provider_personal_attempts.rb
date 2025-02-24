class CreateProviderPersonalAttempts < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_personal_attempts do |t|
      t.string :contact_method
      t.string :attempt_status
      t.date :contact_date
      t.text :comments
      t.references :provider_attest
      t.integer    :caqh_provider_attest_id
      t.references :provider_personal_information, index: false
      t.integer :caqh_provider_id

      t.timestamps
    end

    add_index  :provider_personal_attempts, :provider_personal_information_id, :name => 'ppa_ppi_id'
  end
end