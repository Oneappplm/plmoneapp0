class CreateDeaMasterRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :dea_master_records do |t|
      t.string :dea_number
      t.string :business_activity
      t.string :schedules
      t.date   :expiration_date
      t.string :name
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.string :status
      t.string :degree
      t.string :state_license_number
      t.timestamps
    end

    add_index :dea_master_records, :dea_number
    add_index :dea_master_records, :name
  end
end
