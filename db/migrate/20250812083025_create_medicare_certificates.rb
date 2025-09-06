class CreateMedicareCertificates < ActiveRecord::Migration[7.0]
  def change
    create_table :medicare_certificates do |t|
      t.bigint :provider_attest_id
      t.string :medicare_number
      t.string :status
      t.string :source
      t.date :source_date
      t.string :verified_by
      t.date :verified_date
      t.text :review_criteria

      t.timestamps
    end
      add_index :medicare_certificates, :provider_attest_id, name: "index_medicare_certificates_on_provider_attest_id"  
  end
end
