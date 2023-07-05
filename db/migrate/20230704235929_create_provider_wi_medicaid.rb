class CreateProviderWiMedicaid < ActiveRecord::Migration[7.0]
  def up
    create_table :provider_wi_medicaids do |t|
      t.references :provider
      t.string :wi_medicaid
      t.string :wi_medicaid_username
      t.string :password
      t.string :password_digest
      t.string :question
      t.string :answer
      t.string :notes

      t.timestamps
    end
  end

  def down
    drop_table :provider_wi_medicaids
  end
end
