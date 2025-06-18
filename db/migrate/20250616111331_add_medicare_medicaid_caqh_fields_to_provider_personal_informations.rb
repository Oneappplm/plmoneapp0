class AddMedicareMedicaidCaqhFieldsToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    change_table :provider_personal_informations, bulk: true do |t|
      # Medicare
      t.string :other_id_voluntarily_medicare
      t.string :medicare_field
      t.string :participating_medicare_number
      t.string :participating_medicare_state

      # Medicaid
      t.string :medicaid_field
      t.string :participating_medicaid_number
      t.string :participating_medicaid_state
      t.boolean :participating_medicaid_no_number, default: false

      # CAQH
      t.string :caqh_field
      t.string :caqh_number

      # Other IDs
      t.string :tricare_provider_name
      t.string :usmle_number
      t.string :workers_compensastion_number
      t.string :champs_id_number

      # Other Certifications
      t.string  :other_cert_field
      t.string  :other_certification_type
      t.string  :other_certification_number
      t.string  :other_certification_state
      t.date    :other_certification_issue_date
      t.date    :other_certification_expiration_date
      t.boolean :other_certification_not_expire, default: false
    end
  end
end
