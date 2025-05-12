class RemoveColumns < ActiveRecord::Migration[7.0]
  def change
    remove_column :orders, :crypto_paid, :boolean, default: false
    remove_column :orders, :crypto_txn_signature, :string
    remove_column :orders, :crypto_amount, :decimal, precision: 12, scale: 9
    remove_column :orders, :crypto_memo, :string
    remove_column :orders, :crypto_tx_signature, :string
    remove_column :orders, :crypto_amount_received, :decimal
    remove_column :payments, :crypto_transaction_id, :string
  end
end
