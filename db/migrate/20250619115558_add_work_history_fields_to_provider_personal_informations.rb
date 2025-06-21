class AddWorkHistoryFieldsToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :has_work_history, :string
    add_column :provider_personal_informations, :edc_employment_location, :string
    add_column :provider_personal_informations, :edc_practice_employer_name, :string
    add_column :provider_personal_informations, :no_longer_in_business, :boolean
    add_column :provider_personal_informations, :edc_first_name, :string
    add_column :provider_personal_informations, :edc_last_name, :string
    add_column :provider_personal_informations, :edc_address_line1, :string
    add_column :provider_personal_informations, :edc_address_line2, :string
    add_column :provider_personal_informations, :edc_city, :string
    add_column :provider_personal_informations, :edc_zipcode, :string
    add_column :provider_personal_informations, :edc_telephone_number, :string
    add_column :provider_personal_informations, :edc_ext, :string
    add_column :provider_personal_informations, :edc_email, :string
    add_column :provider_personal_informations, :edc_mcde, :string
    add_column :provider_personal_informations, :edc_contact_method, :string
    add_column :provider_personal_informations, :edc_position_held, :string
    add_column :provider_personal_informations, :edc_start_date, :date
    add_column :provider_personal_informations, :edc_end_date, :date
    add_column :provider_personal_informations, :until_present, :boolean

    # Collaboration-related fields
    add_column :provider_personal_informations, :edc_collab, :string
    add_column :provider_personal_informations, :co_first_name, :string
    add_column :provider_personal_informations, :co_middle_name, :string
    add_column :provider_personal_informations, :co_last_name, :string
    add_column :provider_personal_informations, :co_suffix, :string
    add_column :provider_personal_informations, :co_degree, :string
    add_column :provider_personal_informations, :state_abbr, :string
    add_column :provider_personal_informations, :co_physician_pln, :string
    add_column :provider_personal_informations, :co_medicare_number, :string
    add_column :provider_personal_informations, :co_npi_number, :string
  end
end
