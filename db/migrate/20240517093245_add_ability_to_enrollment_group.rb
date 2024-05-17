class AddAbilityToEnrollmentGroup < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_groups, :group_liability_carrier_name, :string
    add_column :enrollment_groups, :group_liability_self_insured, :string
    add_column :enrollment_groups, :group_liability_address, :string
    add_column :enrollment_groups, :group_liability_city, :string
    add_column :enrollment_groups, :group_liability_state_id, :integer
    add_column :enrollment_groups, :group_liability_zipcode, :string
    add_column :enrollment_groups, :group_liability_orig_effective_date, :date
    add_column :enrollment_groups, :group_liability_effective_date, :date
    add_column :enrollment_groups, :group_liability_expiration_date, :date
    add_column :enrollment_groups, :group_liability_coverage_type, :string
    add_column :enrollment_groups, :group_liability_unlimited_coverage, :string
    add_column :enrollment_groups, :group_liability_tail_coverage, :string
    add_column :enrollment_groups, :group_liability_coverage_amount, :string
    add_column :enrollment_groups, :group_liability_coverage_amount_aggregate, :string
    add_column :enrollment_groups, :group_liability_policy_number, :string
  end
end
