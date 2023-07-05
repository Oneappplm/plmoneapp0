class CreateProviderMnMedicaid < ActiveRecord::Migration[7.0]
  def up
    create_table :provider_mn_medicaids do |t|
      t.references :provider
      t.string :mn_medicaid_number
      t.string :mn_medicaid_username
      t.string :password
      t.string :password_digest
      t.string :question
      t.string :answer
      t.timestamps
    end
  end

  def down
    drop_table :provider_mn_medicaids
  end
end
