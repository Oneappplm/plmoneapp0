class CreateProviderMedicaid < ActiveRecord::Migration[7.0]
  def up
    create_table :provider_medicaids do |t|
      t.references :provider
      t.datetime :effective_date
      t.datetime :reval_date
      t.string :notes
      t.timestamps
    end
  end

  def down
    drop_table :provider_medicaids
  end
end
