class CreateProviderProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_profiles do |t|
      t.references :order, null: false, foreign_key: true
      t.references :provider, null: true, foreign_key: true # can link to your existing provider table
      t.string :first_name
      t.string :last_name
      t.string :npi_number
      t.string :license_number
      t.string :state
      t.integer :status, default: 0 # submitted, verified, failed
      t.timestamps
    end
  end
end
