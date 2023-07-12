class CreateProviderTimelines < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_timelines do |t|
      t.references :provider, null: false, foreign_key: true
      t.string :title
      t.datetime :due_date
      t.string :notes
      t.boolean :status, default: false

      t.timestamps
    end
  end
end
