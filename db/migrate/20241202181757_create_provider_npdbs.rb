class CreateProviderNpdbs < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_npdbs do |t|
      t.references :provider_attest, null: false, foreign_key: true
      t.integer :caqh_provider_attest_id
      t.string :practitioner_type
      t.string :individual_identification_number_1
      t.string :individual_identification_number_2
      t.string :individual_identification_number_3
      t.string :individual_identification_number_4
      t.boolean :show_on_tickler
      t.string :status
      t.string :submit_date
      t.string :response_date
      t.text :comments

      t.timestamps
    end
  end
end
