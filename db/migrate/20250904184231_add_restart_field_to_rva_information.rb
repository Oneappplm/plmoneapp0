class AddRestartFieldToRvaInformation < ActiveRecord::Migration[7.0]
  def change
    add_column :rva_informations, :restart_audit, :boolean
  end
end
