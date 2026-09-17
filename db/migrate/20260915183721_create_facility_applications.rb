class CreateFacilityApplications < ActiveRecord::Migration[7.0]

  def change

    create_table :facility_applications do |t|

      t.string :facility_name, null: false

      t.string :status, default: "draft", null: false

      t.datetime :submitted_at

      t.timestamps

    end
    add_index :facility_applications, :facility_name
    add_index :facility_applications, :status
  end
end