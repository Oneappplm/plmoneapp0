class CreatePracticeCertifications < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_certifications, primary_key: [:provider_attest_id,:provider_practice_certification_id,:provider_practice_id] do |t|
      t.integer       :provider_practice_certification_id
      t.references    :provider_attest
      t.boolean       :certification_flag
      t.datetime      :expiration_date
      t.text          :other_certification_explanation
      t.boolean       :staff_certified_flag
      t.boolean       :provider_certified_flag
      t.text          :certification_description
      t.datetime      :certification_date
      t.integer       :provider_practice_id
      t.timestamps
    end

    add_index  :practice_certifications, :provider_practice_id, :name => 'pc_pp_id'
  end

  def self.down
    drop_table :practice_certifications
  end
end
