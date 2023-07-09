class CreateProvidersTimeLines < ActiveRecord::Migration[7.0]
  def up
    create_table :providers_time_lines do |t|
      t.references :provider
      t.string :title
      t.datetime :due_date
      t.string :notes
      t.string :status, default: "pending"

      t.timestamps
    end
  end

  def down
    drop_table :providers_time_lines
  end
end
