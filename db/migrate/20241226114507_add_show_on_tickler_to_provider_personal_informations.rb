class AddShowOnTicklerToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :show_on_tickler, :boolean
  end
end
