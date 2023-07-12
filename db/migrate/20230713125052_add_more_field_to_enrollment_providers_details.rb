class AddMoreFieldToEnrollmentProvidersDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers_details, :payer_state, :string
  end
end
