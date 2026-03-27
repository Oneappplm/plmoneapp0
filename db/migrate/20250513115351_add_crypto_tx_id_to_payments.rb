class AddCryptoTxIdToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :crypto_transaction_id, :string
  end
end
