# db/migrate/TIMESTAMP_create_dmf_records.rb
# frozen_string_literal: true

class CreateDmfRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :dmf_records do |t|
      t.string :ssn, null: false, limit: 9

      t.string :first_name
      t.string :middle_name
      t.string :last_name

      t.date :birth_date
      t.date :death_date
      t.datetime :source_date

      t.bigint :dmf_file_version_id, null: false
    end

    add_index :dmf_records, :ssn
    add_index :dmf_records, :dmf_file_version_id
  end
end