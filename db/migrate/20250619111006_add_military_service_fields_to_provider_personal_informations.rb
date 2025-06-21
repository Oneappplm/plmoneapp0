class AddMilitaryServiceFieldsToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :served_in_military, :string
    add_column :provider_personal_informations, :military_enlist_base_of_service, :string
    add_column :provider_personal_informations, :mi_mrtd, :string
    add_column :provider_personal_informations, :military_enlist_data, :date
    add_column :provider_personal_informations, :military_discharge_data, :date
    add_column :provider_personal_informations, :military_until_current, :boolean
    add_column :provider_personal_informations, :military_primary_base, :string
    add_column :provider_personal_informations, :military_division, :string
    add_column :provider_personal_informations, :military_primary_base_location, :string
    add_column :provider_personal_informations, :military_address_1, :string
    add_column :provider_personal_informations, :military_address_2, :string
    add_column :provider_personal_informations, :military_city, :string
    add_column :provider_personal_informations, :military_zip_code, :string
    add_column :provider_personal_informations, :military_telephoe, :string
    add_column :provider_personal_informations, :military_ext, :string
    add_column :provider_personal_informations, :military_fax, :string
    add_column :provider_personal_informations, :military_status, :string
    add_column :provider_personal_informations, :military_appointed_date, :date
    add_column :provider_personal_informations, :honorably_discharge, :string
    add_column :provider_personal_informations, :military_discharge_reason, :text
    add_column :provider_personal_informations, :military_court_martialed, :string
    add_column :provider_personal_informations, :court_martialed_reason, :text
    add_column :provider_personal_informations, :military_reserve, :string
    add_column :provider_personal_informations, :military_reserve_branch, :string
  end
end
