class CreatePracticeAssociateSpecialties < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_associate_specialties do |t|
      t.integer     :caqh_provider_practice_associate_specialty_id
      t.references  :provider_attest
      t.integer     :caqh_provider_attest_id
      t.string      :specialty_specialty_name
      t.references  :practice_information
      t.references  :practice_associate
      t.integer     :caqh_provider_practice_id
      t.integer     :caqh_provider_practice_associate_id
      t.timestamps
    end
  end

  def self.down
    drop_table :practice_associate_specialties
  end
end
