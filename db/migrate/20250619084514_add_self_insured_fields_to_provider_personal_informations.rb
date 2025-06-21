class AddSelfInsuredFieldsToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :lf_self_insured_policy_name, :string
    add_column :provider_personal_informations, :lf_self_insured_policy_number, :string
    add_column :provider_personal_informations, :lf_self_insured_carrier_name, :string
    add_column :provider_personal_informations, :lf_self_insured_email_address, :string
    add_column :provider_personal_informations, :lf_self_insured_phone_number, :string
    add_column :provider_personal_informations, :lf_self_insured_ext, :string
    add_column :provider_personal_informations, :lf_self_insured_fax_number, :string
    add_column :provider_personal_informations, :lf_self_insured_coverage_amount, :string
    add_column :provider_personal_informations, :lf_self_insured_unlimited_coverage_amount, :boolean
    add_column :provider_personal_informations, :lf_self_insured_email_aggregate_coverage, :string
    add_column :provider_personal_informations, :lf_self_insured_unlimited_aggregate_coverage, :boolean
    add_column :provider_personal_informations, :lf_self_insured_original_effective_date, :date
    add_column :provider_personal_informations, :lf_self_insured_effective_date, :date
    add_column :provider_personal_informations, :lf_self_insured_original_expiration_date, :date
    add_column :provider_personal_informations, :lf_self_insured_not_expiry, :boolean
  end
end
