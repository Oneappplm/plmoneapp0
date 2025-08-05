class CreateProviderEnrollmentGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_enrollment_groups do |t|
      t.references :provider, null: false, foreign_key: true
      t.integer :group_id
      t.text :primary_location
      t.text :additional_locations

      t.timestamps
    end
  end
end
