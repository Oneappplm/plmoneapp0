class AddGuidColumnToPpi < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :practitioner_guid, :string
  end
end
