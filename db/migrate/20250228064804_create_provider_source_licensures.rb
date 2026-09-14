class CreateProviderSourceLicensures < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_source_licensures do |t|
      t.references :provider_source, null: false, foreign_key: true

      t.timestamps
    end
  end
end
