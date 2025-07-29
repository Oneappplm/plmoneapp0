class AddCryptoPaymentFieldsToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :payment_memo, :string
    add_column :orders, :crypto_paid, :boolean, default: false
    add_column :orders, :crypto_txn_signature, :string
    add_column :orders, :crypto_amount, :decimal, precision: 12, scale: 9
  end
end