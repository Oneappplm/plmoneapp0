class CreateProviderSourceCme < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_source_cmes do |t|
      t.references :provider_source
      t.string :training
      t.string :month_attended
      t.string :year_attended
      t.string :hours

      t.timestamps
    end
  end
end
