class AddEncompassIdTextToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :encompass_id_text, :string
  end
end
