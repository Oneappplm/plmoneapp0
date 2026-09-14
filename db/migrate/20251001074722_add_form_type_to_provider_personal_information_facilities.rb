class AddFormTypeToProviderPersonalInformationFacilities < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_information_facilities, :form_type, :string
  end
end
