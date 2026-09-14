class CreateAdmittingArrangements < ActiveRecord::Migration[7.0]
  def change
    create_table :admitting_arrangements do |t|
      t.references :provider_source, null: false, foreign_key: true
      t.string :physician_practice_name
      t.string :facility_name
      t.string :facility_address_line1
      t.string :facility_address_line2
      t.string :facility_city
      t.string :facility_zipcode
      t.text :explanation
      t.string :admitting_physician_practice_clinic_group
      t.string :admit_state
      t.text :admitting_arrangements

      t.timestamps
    end
  end
end
