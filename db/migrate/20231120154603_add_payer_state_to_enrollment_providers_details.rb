class AddPayerStateToEnrollmentProvidersDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers_details, :payer_state, :string, if_not_exists: true
  end
end
