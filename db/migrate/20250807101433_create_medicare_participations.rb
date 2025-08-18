class CreateMedicareParticipations < ActiveRecord::Migration[7.0]
  def change
    create_table :medicare_participations do |t|
      t.bigint :provider_attest_id
      t.string :medicare_participating
      t.string :status
      t.string :source
      t.date :source_date
      t.date :verified_date
      t.string :verified_by
      t.string :review_criteria

      t.timestamps
    end    
      add_index :medicare_participations, :provider_attest_id, name: "index_medicare_participations_on_provider_attest_id"  
  end
end
