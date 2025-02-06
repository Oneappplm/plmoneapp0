class AddProviderPersonalInformationReferenceToRvaInformation < ActiveRecord::Migration[7.0]
  def change
    add_reference :rva_informations, :provider_personal_information, null: false, foreign_key: true
  end
end
