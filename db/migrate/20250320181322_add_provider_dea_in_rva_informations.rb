class AddProviderDeaInRvaInformations < ActiveRecord::Migration[7.0]
  def change
    add_reference :rva_informations, :provider_dea, foreign_key: true
  end
end
