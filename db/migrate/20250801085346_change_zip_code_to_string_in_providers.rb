class ChangeZipCodeToStringInProviders < ActiveRecord::Migration[7.0]
  def change
    change_column :providers, :zip_code, :string
  end
end
