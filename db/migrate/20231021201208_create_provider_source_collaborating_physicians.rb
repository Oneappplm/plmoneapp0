class CreateProviderSourceCollaboratingPhysicians < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_source_collaborating_physicians do |t|
      t.integer :provider_source_id
      t.string :first_name
      t.string :last_name
      t.string :middle_name
      t.string :suffix
      t.string :degree
      t.string :state_license
      t.string :license_number
      t.string :medicare_number
      t.string :npi_number
      t.timestamps
    end
  end
end
