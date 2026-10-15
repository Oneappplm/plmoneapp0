class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :client_organization, null: false, foreign_key: true
      t.string :status, default: "pending"
      t.decimal :total_amount, precision: 10, scale: 2, default: 0.0
      t.timestamps
    end
  end
end
