class CreateProviderPersonalAttempts < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_personal_attempts do |t|
      t.string :contact_method
      t.string :attempt_status
      t.date :contact_date
      t.text :comments
      t.references :provider_attest, null: false,  foreign_key: { to_table: :provider_attests, primary_key: :provider_attest_id }
      t.integer :provider_id

      t.timestamps
    end
  end
end
