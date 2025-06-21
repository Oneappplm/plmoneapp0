class AddInsuranceDetailsToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :lf_carrier_location, :string
    add_column :provider_personal_informations, :lf_carrier_name, :string
    add_column :provider_personal_informations, :lf_address_line1, :string
    add_column :provider_personal_informations, :lf_address_line2, :string
    add_column :provider_personal_informations, :lf_city, :string
    add_column :provider_personal_informations, :lf_zipcode, :string
    add_column :provider_personal_informations, :lf_telephone_number, :string
    add_column :provider_personal_informations, :lf_ext, :string
    add_column :provider_personal_informations, :lf_fax_number, :string
    add_column :provider_personal_informations, :lf_email_address, :string
    add_column :provider_personal_informations, :lf_policy_type, :string
    add_column :provider_personal_informations, :lf_coverage_type, :string
    add_column :provider_personal_informations, :lf_policy_holder_name, :string
    add_column :provider_personal_informations, :lf_policy_number, :string
    add_column :provider_personal_informations, :has_tail_coverage, :string
    add_column :provider_personal_informations, :has_carrier_excluded, :string
    add_column :provider_personal_informations, :lf_not_insured_coverage_amount, :string
    add_column :provider_personal_informations, :lf_not_insured_unlimited_coverage_amount, :boolean
    add_column :provider_personal_informations, :lf_not_insured_email_aggregate_coverage, :string
    add_column :provider_personal_informations, :lf_not_insured_unlimited_aggregate_coverage, :boolean
    add_column :provider_personal_informations, :lf_not_insured_original_effective_date, :date
    add_column :provider_personal_informations, :lf_not_insured_effective_date, :date
    add_column :provider_personal_informations, :lf_not_insured_original_expiration_date, :date
    add_column :provider_personal_informations, :lf_not_insured_not_expiry, :boolean
  end
end
