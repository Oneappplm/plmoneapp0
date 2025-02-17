class AddFieldsInProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :caqh_provider_id, :integer if !column_exists?(:provider_personal_informations, :caqh_provider_id)
    add_column :provider_personal_informations, :caqh_provider_attest_id, :integer if !column_exists?(:provider_personal_informations, :caqh_provider_attest_id)
  end
end
