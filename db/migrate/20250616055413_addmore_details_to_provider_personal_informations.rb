class AddmoreDetailsToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    change_table :provider_personal_informations do |t|
      t.date :ps_dob
      t.string :ps_citizenship
      t.string :ps_cob
      t.boolean :ps_ssn
      t.string :social_security_number
      t.boolean :reside_on_us
      t.boolean :work_on_us
      t.boolean :permanent_work_permit
      t.string :foreign_national_identification_number
      t.string :fnin_country_of_issue
      t.string :gi_visa_types
      t.date   :ps_vid
      t.date   :ps_ved
      t.string :languages_you_speak, array: true, default: []
      t.string :languages_you_write, array: true, default: []
      t.string :ethnicity
      t.string :marital_status
      t.string :emergency_first_name
      t.string :emergency_middle_name
      t.string :emergency_last_name
      t.string :emergency_contact_phone_number
    end
  end
end
