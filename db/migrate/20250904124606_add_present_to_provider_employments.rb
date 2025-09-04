class AddPresentToProviderEmployments < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_employments, :present, :boolean
  end
end
