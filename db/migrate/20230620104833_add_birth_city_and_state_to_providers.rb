class AddBirthCityAndStateToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :birth_city, :string
    add_column :providers, :birth_state, :string
  end
end
