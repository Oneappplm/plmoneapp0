class CreateEpdAttempts < ActiveRecord::Migration[7.0]
  def change
    create_table :epd_attempts do |t|
      t.string :attempt_date
      t.string :status
      t.string :note
      t.references :user
      t.references :enrollment_providers_detail
      t.timestamps
    end
  end
end