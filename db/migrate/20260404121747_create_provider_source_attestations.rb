class CreateProviderSourceAttestations < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_source_attestations do |t|
      t.references :provider_source, null: false, foreign_key: true
      t.date :signature_date
      t.integer :attested_by
      t.timestamps
    end
  end
end
