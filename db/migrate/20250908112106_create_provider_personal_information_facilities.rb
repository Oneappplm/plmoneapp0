class CreateProviderPersonalInformationFacilities < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_personal_information_facilities do |t|
      t.references :provider_attest, index: { name: "idx_facilities_attest_id" }
      t.integer :caqh_provider_attest_id
      t.string :facility_name
      t.string :contact
      t.string :address
      t.string :addition_address
      t.string :city
      t.string :county
      t.string :state
      t.string :zip_code
      t.string :country
      t.string :facility_office_pnone
      t.string :facility_office_fax
      t.string :facility_office_email
      t.date :appointment_date
      t.string :department
      t.string :section_name
      t.string :facility_chair
      t.string :facility_chair_title
      t.string :status
      t.boolean :is_current
      t.boolean :is_primary_admitting_facility
      t.date :expiration_date
      t.boolean :is_restriction_of_privileges
      t.boolean :is_admit_patients_facility
      t.string :faciltiy_percentage
      t.boolean :is_hospital_based_practitioner
      t.boolean :is_admitting_arrangements
      t.boolean :is_following_physician
      t.boolean :show_on_tickler
      t.text :comments

      t.timestamps
    end
  end
end
