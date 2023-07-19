class CreateProvidersMissingFieldSubmissions < ActiveRecord::Migration[7.0]
  def up
    create_table :providers_missing_field_submissions do |t|
      t.references :provider
      t.integer :completed_by #user_id
      t.string :status, default: 'pending'

      t.timestamps
    end
  end

  def down
    drop_table :providers_missing_field_submissions
  end
end


 