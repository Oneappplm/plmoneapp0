class AddNewColumnsToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :board_name, :string
    add_column :providers, :board_certificate_number, :string
    add_column :providers, :board_effective_date, :date
    add_column :providers, :board_recertification_date, :date
    add_column :providers, :board_expiration_date, :date
    add_column :providers, :prof_medical_school_name, :string
    add_column :providers, :prof_medical_school_address, :string
    add_column :providers, :prof_medical_school_city, :string
    add_column :providers, :prof_medical_school_state_id, :integer
    add_column :providers, :prof_medical_school_country, :string
    add_column :providers, :prof_medical_school_zipcode, :string
    add_column :providers, :prof_medical_start_date, :date
    add_column :providers, :prof_medical_school_degree_awarded, :string
    add_column :providers, :prof_liability_carrier_name, :string
    add_column :providers, :prof_liability_self_insured, :string
    add_column :providers, :prof_liability_address, :string
    add_column :providers, :prof_liability_city, :string
    add_column :providers, :prof_liability_state_id, :integer
    add_column :providers, :prof_liability_zipcode, :string
    add_column :providers, :prof_liability_orig_effective_date, :date
    add_column :providers, :prof_liability_effective_date, :date
    add_column :providers, :prof_liability_expiration_date, :date
    add_column :providers, :prof_liability_coverage_type, :string
    add_column :providers, :prof_liability_unlimited_coverage, :string
    add_column :providers, :prof_liability_tail_coverage, :string
    add_column :providers, :prof_liability_coverage_amount, :string
    add_column :providers, :prof_liability_coverage_amount_aggregate, :string
    add_column :providers, :prof_liability_policy_number, :string

  end
end
