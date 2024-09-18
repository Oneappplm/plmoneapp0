class CreatePracticeCertifications < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_certifications do |t|
      t.integer       :caqh_provider_practice_certification_id
      t.references    :provider_attest
      t.integer       :caqh_provider_attest_id
      t.boolean       :certification_flag
      t.datetime      :expiration_date
      t.text          :other_certification_explanation
      t.boolean       :staff_certified_flag
      t.boolean       :provider_certified_flag
      t.text          :certification_description
      t.datetime      :certification_date
      t.references    :practice_information
      t.integer       :caqh_provider_practice_id
      t.timestamps
    end
  end

  def self.down
    drop_table :practice_certifications
  end
end
