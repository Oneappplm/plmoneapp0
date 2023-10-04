class AddEffectiveDateToGroupDcoOldLocationAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :group_dco_old_location_addresses, :effective_date, :date
  end
end
