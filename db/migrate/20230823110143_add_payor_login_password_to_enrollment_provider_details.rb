class AddPayorLoginPasswordToEnrollmentProviderDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers_details, :payor_username, :string
    add_column :enrollment_providers_details, :payor_password, :string
  end
end
