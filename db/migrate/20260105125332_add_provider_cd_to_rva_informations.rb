class AddProviderCdToRvaInformations < ActiveRecord::Migration[7.0]
  def change
    add_reference :rva_informations, :provider_cd, null: true, foreign_key: true
  end
end
  