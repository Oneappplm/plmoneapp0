class CreatePracticeCertifications < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_certifications, id: false do |t|
      t.primary_key   :provider_practice_certification_id
      t.references    :provider_attest
      t.boolean       :certification_flag
      t.datetime      :expiration_date
      t.text          :other_certification_explanation
      t.boolean       :staff_certified_flag
      t.boolean       :provider_certified_flag
      t.text          :certification_description
      t.datetime      :certification_date

      t.timestamps
    end

    add_column :practice_certifications, :provider_practice_id, :integer
    add_index  :practice_certifications, :provider_practice_id, :name => 'pc_pp_id'
  end

  def self.down
    drop_table :practice_certifications
  end
end
