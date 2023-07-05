class CreateProviderMcc < ActiveRecord::Migration[7.0]
  # created this table in the case this will be multilple in the future
  def up
    create_table :provider_mccs do |t|
      t.references :provider
      t.string :mcc_username
      t.string :password
      t.string :password_digest
      t.string :mcc_electronic_signature_code
      t.timestamps
    end
  end

  def down
    drop_table :provider_mccs
  end
end
