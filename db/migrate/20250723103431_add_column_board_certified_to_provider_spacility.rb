class AddColumnBoardCertifiedToProviderSpacility < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_specialties, :board_certified, :boolean
  end
end
