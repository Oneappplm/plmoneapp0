class CreateCertifications < ActiveRecord::Migration[7.0]
  def change
    create_table :certifications do |t|
      t.string :type
      t.string :issuing_agency
      t.string :certification_status
      t.string :certification_number
      t.date :initial_certification_date
      t.date :recertification_dates
      t.date :certification_expiration_date
      t.boolean :does_not_expire
      t.text :comments
      t.boolean :show_on_tickler
      t.integer        :caqh_provider_attest_id
      t.references :provider_attest, null: false, foreign_key: true

      t.timestamps
    end
  end
end
