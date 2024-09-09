class UpdateProviderMedicalLicensesLicenseNumberType < ActiveRecord::Migration[7.0]
  def self.up
    change_column :provider_medical_licenses, :license_number, :string
  end

  def self.down
    change_column :provider_medical_licenses, :license_number, :integer
  end
end
