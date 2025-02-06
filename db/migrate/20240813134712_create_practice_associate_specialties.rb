class CreatePracticeAssociateSpecialties < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_associate_specialties, primary_key: [:provider_attest_id, :provider_practice_associate_specialty_id, :provider_practice_associate_id, :provider_practice_id] do |t|
      t.integer     :provider_practice_associate_specialty_id
      t.references  :provider_attest
      t.string      :specialty_specialty_name
      t.integer     :provider_practice_id
      t.integer     :provider_practice_associate_id
      t.timestamps
    end

    add_index  :practice_associate_specialties, :provider_practice_associate_specialty_id, :name => 'pas_id'
    add_index  :practice_associate_specialties, :provider_practice_id, :name => 'pas_pp_id'
    add_index  :practice_associate_specialties, :provider_practice_associate_id, :name => 'pas_ppa_id'
  end

  def self.down
    drop_table :practice_associate_specialties
  end
end
