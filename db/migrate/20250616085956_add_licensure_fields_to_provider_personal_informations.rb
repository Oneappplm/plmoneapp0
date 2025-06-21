class AddLicensureFieldsToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :state_license_specialty, :string
    add_column :provider_personal_informations, :licensure_state, :string
    add_column :provider_personal_informations, :license_type, :string
    add_column :provider_personal_informations, :license_number, :string
    add_column :provider_personal_informations, :license_status, :string
    add_column :provider_personal_informations, :licensure_issue_date, :date
    add_column :provider_personal_informations, :licensure_expiration_date, :date
    add_column :provider_personal_informations, :licensure_not_expire, :boolean
    add_column :provider_personal_informations, :licensure_practice_state, :string
    add_column :provider_personal_informations, :licensure_primary_license, :string
    add_column :provider_personal_informations, :licensure_require_supervision, :string

    # Sponsor Details
    add_column :provider_personal_informations, :licensure_sponsor_fname, :string
    add_column :provider_personal_informations, :licensure_sponsor_mname, :string
    add_column :provider_personal_informations, :licensure_sponsor_lname, :string
    add_column :provider_personal_informations, :licensure_sponsor_suffix, :string
    add_column :provider_personal_informations, :licensure_sponsor_degree, :string
  end
end
