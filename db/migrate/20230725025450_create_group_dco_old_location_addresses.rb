class CreateGroupDcoOldLocationAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :group_dco_old_location_addresses do |t|
      t.references :group_dco, null: false, foreign_key: true
      t.string :old_address
      t.string :old_city
      t.string :old_state
      t.string :old_zipcode
      t.string :old_county
      t.boolean :is_old_location_primary, default: false

      t.timestamps
    end
  end
end
