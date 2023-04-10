class CreateProviderSourceData < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_source_data do |t|
      t.references :provider_source, null: false, foreign_key: true
      t.string :data_key
      t.string :data_value

      t.timestamps
    end
  end
end
