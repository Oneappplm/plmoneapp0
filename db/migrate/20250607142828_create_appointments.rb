class CreateAppointments < ActiveRecord::Migration[7.0]
  def change
    create_table :appointments do |t|
      t.references :provider, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.datetime :appointment_date
      t.string :reason
      t.string :status

      t.timestamps
    end
  end
end
