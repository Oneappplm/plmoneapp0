class AddNewPayerStateToEnrollmentProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers, :payer_state, :string, if_not_exists: true
  end
end
