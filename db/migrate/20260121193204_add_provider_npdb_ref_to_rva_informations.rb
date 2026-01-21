class AddProviderNpdbRefToRvaInformations < ActiveRecord::Migration[7.0]
  def change
    add_reference :rva_informations, :provider_npdb, foreign_key: true, index: true
  end
end
