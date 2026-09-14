class AddShowOnTicklerToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:provider_personal_informations, :show_on_tickler)
      add_column :provider_personal_informations, :show_on_tickler, :boolean, default: false
    end
  end
end
