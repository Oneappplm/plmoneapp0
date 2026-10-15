class AddCryptoFieldsToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :crypto_memo, :string
    add_column :orders, :crypto_tx_signature, :string
    add_column :orders, :crypto_amount_received, :decimal
  end
end
