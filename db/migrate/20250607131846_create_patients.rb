class CreatePatients < ActiveRecord::Migration[7.0]
  def change
    create_table :patients do |t|
      t.references :provider, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.date :dob
      t.text :medical_history
      t.string :emergency_contact
      t.string :status

      t.timestamps
    end
  end
end
