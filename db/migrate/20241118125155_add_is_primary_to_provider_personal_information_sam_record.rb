class AddIsPrimaryToProviderPersonalInformationSamRecord < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_information_sam_records, :is_primary, :boolean, default: false
    remove_column :provider_personal_information_sam_records, :name_type, :string
  end
end
