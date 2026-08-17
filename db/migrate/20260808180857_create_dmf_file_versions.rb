# db/migrate/TIMESTAMP_create_dmf_file_versions.rb
# frozen_string_literal: true

class CreateDmfFileVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :dmf_file_versions do |t|
      t.string :source_filename, null: false
      t.string :artifact_key, null: false
      t.string :sha256, null: false

      t.date :publication_date

      t.bigint :row_count
      t.string :status, null: false, default: "pending"

      t.boolean :active, null: false, default: false

      t.datetime :import_started_at
      t.datetime :import_completed_at
      t.text :error_message

      t.timestamps
    end

    add_index :dmf_file_versions, :status
    add_index :dmf_file_versions, :active
    add_index :dmf_file_versions, :publication_date
    add_index :dmf_file_versions, :sha256, unique: true
  end
end