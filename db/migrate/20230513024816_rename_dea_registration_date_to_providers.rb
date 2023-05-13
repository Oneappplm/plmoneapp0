class RenameDeaRegistrationDateToProviders < ActiveRecord::Migration[7.0]
  def change
    remove_column :providers, :dea_registration_date
    add_column :providers, :dea_registration_state, :string
  end
end
