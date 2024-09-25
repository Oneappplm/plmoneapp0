class CreateWorkHistoryProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :work_history_providers do |t|
      t.string :practice_name
      t.string :location
      t.date :start_date
      t.date :end_date
      t.integer :tax_id
      t.string :reasone_of_leaving
      t.references :provider

      t.timestamps
    end
  end
end
