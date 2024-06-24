class AddPayorEmailPhoneToEnrollmentProviderDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers_details, :payor_email, :string
    add_column :enrollment_providers_details, :payor_phone, :string
  end
end
