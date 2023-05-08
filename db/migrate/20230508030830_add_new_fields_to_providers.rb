class AddNewFieldsToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :address_line_1, :string
    add_column :providers, :address_line_2, :string
    add_column :providers, :city, :string
    add_column :providers, :state, :string
    add_column :providers, :telephone_number, :string
    add_column :providers, :ext, :string
    add_column :providers, :email_address, :string
    add_column :providers, :dea_registration_date, :string
    add_column :providers, :provider_hire_date_seeing_patient, :date
    add_column :providers, :effective_date_seeing_patient, :date
    add_column :providers, :medicare_provider_number, :string
    add_column :providers, :medicaid_provider_number, :string
    add_column :providers, :tricare_provider_number, :string
    add_column :providers, :admitting_privileges, :string
    add_column :providers, :revalidation, :string
    add_column :providers, :employed_by_other, :string
    add_column :providers, :supervised_by_psychologist, :string
    add_column :providers, :medical_school_name, :string
    add_column :providers, :medical_school_address, :string
    add_column :providers, :graduation_date, :date
    add_column :providers, :school_certificate, :string
    add_column :providers, :caqh_username, :string
    add_column :providers, :caqh_password, :string
    add_column :providers, :caqh_state, :string
    add_column :providers, :caqh_app, :string
    add_column :providers, :caqh_payor, :string
    add_column :providers, :telehealth_license_number, :string
    add_column :providers, :board_certification_number, :string
  end
end
