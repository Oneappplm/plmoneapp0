class AddCreatedByFieldToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :created_by, :string
  end
end
