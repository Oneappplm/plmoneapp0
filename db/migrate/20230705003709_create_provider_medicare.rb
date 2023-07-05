class CreateProviderMedicare < ActiveRecord::Migration[7.0]
  def up
    create_table :provider_medicares do |t|
      t.references :provider
      t.string :ptan_number
      t.datetime :effective_date
      t.string :medicare_username
      t.string :password
      t.string :password_digest
      t.string :question
      t.string :answer
      t.datetime :reval_date
      t.string :notes
      t.timestamps
    end
  end

  def down
    drop_table :provider_medicares
  end
end
