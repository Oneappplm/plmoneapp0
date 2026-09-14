class AddFieldsToProviderInsuranceCoverages < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_insurance_coverages, :type_of_policy, :string
    add_column :provider_insurance_coverages, :additional_address, :string
    add_column :provider_insurance_coverages, :email_address, :string
    add_column :provider_insurance_coverages, :effective_date, :date
    add_column :provider_insurance_coverages, :claim_amount, :integer
    add_column :provider_insurance_coverages, :umbrella_coverage_amount, :integer
    add_column :provider_insurance_coverages, :tail_coverage, :boolean
    add_column :provider_insurance_coverages, :current_carrier_excluded, :boolean
    add_column :provider_insurance_coverages, :current_carrier_excluded_explanation, :string
    add_column :provider_insurance_coverages, :show_on_tickler, :boolean
    add_column :provider_insurance_coverages, :comment, :text
    add_column :provider_insurance_coverages, :liability_not_applicable, :boolean
    add_column :provider_insurance_coverages, :liability_explanation, :text
  end
end
