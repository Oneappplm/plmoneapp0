class AddApiTokenToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :api_token, :string
  end
end
