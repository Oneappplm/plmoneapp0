class CreatePracticeAssociateSpecialties < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_associate_specialties, id: false do |t|
      t.primary_key :provider_practice_associate_specialty_id
      t.references  :provider_attest
      t.string      :specialty_specialty_name

      t.timestamps
    end

    add_column :practice_associate_specialties, :provider_practice_id, :integer
    add_column :practice_associate_specialties, :provider_practice_associate_id, :integer

    add_index  :practice_associate_specialties, :provider_practice_id, :name => 'pas_pp_id'
    add_index  :practice_associate_specialties, :provider_practice_associate_id, :name => 'pas_ppa_id'
  end

  def self.down
    drop_table :practice_associate_specialties
  end
end
