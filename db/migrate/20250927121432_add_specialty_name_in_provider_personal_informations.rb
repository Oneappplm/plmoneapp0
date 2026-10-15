class AddSpecialtyNameInProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :specialty_name_1, :string
    add_column :provider_personal_informations, :specialty_name_2, :string
    add_column :provider_personal_informations, :specialty_name_3, :string
    add_column :provider_personal_informations, :specialty_name_4, :string
    add_column :provider_personal_informations, :specialty_name_5, :string
  end
end
