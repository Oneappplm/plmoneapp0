class CreateAppTrackers < ActiveRecord::Migration[7.0]
  def change
    create_table :app_trackers do |t|
      t.string :application_type
      t.date :application_receipt_date
      t.date :application_receive_complete_date
      t.date :verifications_complete_date
      t.date :file_return_to_client_date
      t.date :output_file_date
      t.string :owner
      t.date :application_submitted_date
      t.references :practitioner, null: false, foreign_key: true

      t.timestamps
    end
  end
end
