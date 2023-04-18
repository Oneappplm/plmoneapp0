class CreateProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :providers do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :suffix
      t.string :gender
      t.date :birth_date
      t.string :practitioner_type
      t.string :ssn
      t.string :npi
      t.string :caqhid
      t.date :caqh_attestation_date
      t.string :caqh_pdf
      t.date :caqh_pdf_date_received
      t.string :nccpa_number
      t.string :dea_number
      t.date :dea_license_effective_date
      t.date :dea_license_expiration_date
      t.string :dco
      t.string :dco_file
      t.date :pa_license_effective_date
      t.date :pa_license_expiration_date

      t.timestamps
    end
  end
end
