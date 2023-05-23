class CreateWebscraperCaliforniaStates < ActiveRecord::Migration[7.0]
  def change
    create_table :webscraper_california_states do |t|
      t.string :name
      t.string :license_number
      t.string :license_type
      t.string :license_status
      t.string :license_expiration
      t.string :secondary_status
      t.string :city
      t.string :state
      t.string :county
      t.string :zip

      t.timestamps
    end
  end
end
