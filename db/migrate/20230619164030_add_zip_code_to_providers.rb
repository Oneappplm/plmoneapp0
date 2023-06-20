class AddZipCodeToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :zip_code, :integer
  end
end
