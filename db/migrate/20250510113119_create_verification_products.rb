class CreateVerificationProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :verification_products do |t|
      t.string :name, null: false
      t.string :description
      t.decimal :price, precision: 8, scale: 2, default: 0.0
      t.integer :status, default: 0 # active, inactive
      t.timestamps
    end
  end
end
