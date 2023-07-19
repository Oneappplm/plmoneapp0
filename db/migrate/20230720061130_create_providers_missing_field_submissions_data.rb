class CreateProvidersMissingFieldSubmissionsData < ActiveRecord::Migration[7.0]
  def up
    create_table :providers_missing_field_submissions_data do |t|
      t.integer :providers_missing_field_submission_id
      t.string :data_attribute
      t.string :data_key
      t.string :data_value
      t.timestamps
    end
  end

  def down
    drop_table :providers_missing_field_submissions_data
  end
end
