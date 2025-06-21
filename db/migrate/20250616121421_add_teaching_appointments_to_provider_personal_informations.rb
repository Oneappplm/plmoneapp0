class AddTeachingAppointmentsToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :an_instructor, :string
    add_column :provider_personal_informations, :taf_location, :string
    add_column :provider_personal_informations, :taf_psn, :string
    add_column :provider_personal_informations, :taf_address_line1, :string
    add_column :provider_personal_informations, :taf_address_line2, :string
    add_column :provider_personal_informations, :taf_city, :string
    add_column :provider_personal_informations, :taf_zipcode, :string
    add_column :provider_personal_informations, :taf_telephone_number, :string
    add_column :provider_personal_informations, :taf_ext, :string
    add_column :provider_personal_informations, :taf_fax_number, :string
    add_column :provider_personal_informations, :taf_email, :string
    add_column :provider_personal_informations, :taf_pd_first_name, :string
    add_column :provider_personal_informations, :taf_pd_last_name, :string
    add_column :provider_personal_informations, :taf_pd_degree, :string
    add_column :provider_personal_informations, :taf_ar_degree, :string
    add_column :provider_personal_informations, :taf_start_date, :date
    add_column :provider_personal_informations, :taf_end_date, :date
    add_column :provider_personal_informations, :taf_does_not_expire, :boolean, default: false
  end
end
