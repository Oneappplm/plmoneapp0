class CreateProviderHospitalPrivileges < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_hospital_privileges, primary_key: [:provider_attest_id,:provider_hospital_id] do |t|
      t.integer        :provider_hospital_id
      t.references     :provider_attest
      t.integer        :aha_hospital_id
      t.string         :hospital_name
      t.string         :address
      t.string         :address2
      t.string         :city
      t.string         :state
      t.string         :zip_code
      t.string         :phone_number
      t.boolean        :unrestricted_privileges_flag
      t.text           :privilege_description
      t.boolean        :temporary_privileges_flag
      t.integer        :admission_percent
      t.datetime       :start_date
      t.datetime       :end_date
      t.string         :staff_category
      t.text           :privilege_restriction_explanation
      t.boolean        :application_date
      t.text           :no_privileges_explanation
      t.string         :fax_number
      t.string         :email_address
      t.text           :exit_explanation
      t.boolean        :admit_inpatient_flag
      t.string         :contact_name
      t.string         :province
      t.string         :department_telephone_number
      t.string         :medical_staff_fax_number
      t.string         :department_name
      t.text           :specialty_limitation_explanation
      t.string         :website
      t.text           :coverage_arrangement_explanation
      t.integer        :admits_per_month
      t.text           :hospital_affiliation_type_hospital_affiliation_type_description
      t.string         :country_country_name

      t.timestamps
    end

  end

  def self.down
    drop_table :provider_hospital_privileges
  end
end
