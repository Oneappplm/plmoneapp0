class AddProviderSourceIdToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
     add_column :provider_personal_informations, :provider_source_id, :integer
     add_index :provider_personal_informations, :provider_source_id, unique: true
  end
end
