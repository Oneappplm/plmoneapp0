class CreateProvidersPayerLogins < ActiveRecord::Migration[7.0]
  def up
    create_table :providers_payer_logins do |t|
      t.references :provider
      t.string :enrollment_payer
      t.integer :state_id
      t.string :username
      t.string :password
      t.string :password_digest
      t.text :notes
      t.timestamps
    end
  end

  def down
    drop_table :providers_payer_logins
  end
end
