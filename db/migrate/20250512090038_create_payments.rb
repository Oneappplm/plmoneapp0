class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :stripe_payment_intent_id
      t.string :status, default: "pending"
      t.timestamps
    end
  end
end
