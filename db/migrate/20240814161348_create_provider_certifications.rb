class CreateProviderCertifications < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_certifications, id: false do |t|
      t.primary_key  :provider_certification_id
      t.references   :provider_attest
      t.string       :certification_flag
      t.string       :expiration_date
      t.datetime     :classification_description
      t.datetime     :certification_type
      t.boolean      :certification_status
      t.text         :certification_number
      t.string       :state
      t.string       :obtained_date
      t.string       :relinquished_date
      t.string       :relinquished_explanation
      t.string       :other_certification_explanation
      t.string       :certification_description
      t.string       :country_country_name

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_certifications
  end
end
