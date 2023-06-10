class AddFieldsToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :roster_result, :string
    add_column :providers, :terminated, :string
    add_column :providers, :dco_name, :string
    add_column :providers, :taxonomy, :string
    add_column :providers, :specialty, :string
    add_column :providers, :caqh_id, :string
    add_column :providers, :license_number, :string
    add_column :providers, :license_effective_date, :string
    add_column :providers, :license_expiration_date, :string
    add_column :providers, :np_license_number, :string
    add_column :providers, :np_license_effective_date, :string
    add_column :providers, :np_license_expiration_date, :string
    add_column :providers, :rn_license_number, :string
    add_column :providers, :rn_license_effective_date, :string
    add_column :providers, :rn_license_expiration_date, :string
    add_column :providers, :dea_effective_date, :string
    add_column :providers, :dea_expiration_date, :string
    add_column :providers, :liability_issue_date, :string
    add_column :providers, :liability_expiration_date, :string
    add_column :providers, :policy_number, :string
    add_column :providers, :oig, :string
    add_column :providers, :sam, :string
    add_column :providers, :medicare, :string
    add_column :providers, :medicare_revalidation_date, :string
    add_column :providers, :medicaid, :string
    add_column :providers, :medicaid_revalidation_date, :string
    add_column :providers, :molina, :string
    add_column :providers, :mclaren, :string
    add_column :providers, :meridian, :string
    add_column :providers, :aetna, :string
    add_column :providers, :priority_health, :string
    add_column :providers, :amerihealth, :string
  end
end
