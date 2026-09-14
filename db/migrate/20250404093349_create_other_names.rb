class CreateOtherNames < ActiveRecord::Migration[7.0]
  def change
    create_table :other_names do |t|
      t.references :provider_source, null: false, foreign_key: true
      t.string :name_type
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :suffix
      t.date :date_started
      t.date :date_stopped
      t.boolean :in_use

      t.timestamps
    end
  end
end
