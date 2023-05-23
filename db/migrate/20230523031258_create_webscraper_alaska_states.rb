class CreateWebscraperAlaskaStates < ActiveRecord::Migration[7.0]
  def change
    create_table :webscraper_alaska_states do |t|
      t.string :program
      t.string :license_number
      t.string :dba
      t.string :owners
      t.string :status
      t.string :license_expiration

      t.timestamps
    end
  end
end
