class AddProviderToEnrollmentProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers, :provider_id, :integer
  end
end
