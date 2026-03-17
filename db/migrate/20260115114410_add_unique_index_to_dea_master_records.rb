# db/migrate/20260115114410_add_unique_index_to_dea_master_records.rb
class AddUniqueIndexToDeaMasterRecords < ActiveRecord::Migration[7.0]
  disable_ddl_transaction! # important if you later want CONCURRENTLY

  def up
    # 1) Remove duplicates: keep the newest (highest id) per dea_number
    execute <<~SQL
      DELETE FROM dea_master_records a
      USING dea_master_records b
      WHERE a.dea_number = b.dea_number
        AND a.id < b.id;
    SQL

    # 2) Remove old index if exists
    remove_index :dea_master_records, :dea_number if index_exists?(:dea_master_records, :dea_number)

    # 3) Add unique index
    add_index :dea_master_records, :dea_number, unique: true, name: "index_dea_master_records_on_dea_number"
  end

  def down
    remove_index :dea_master_records, name: "index_dea_master_records_on_dea_number"
    add_index :dea_master_records, :dea_number unless index_exists?(:dea_master_records, :dea_number)
  end
end
