class AddCryptoFieldsToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :crypto_type, :integer
    add_column :invoices, :blockchain_network, :integer
    add_column :invoices, :conversion_rate, :decimal
    add_column :invoices, :sender_wallet_address, :string
    add_column :invoices, :receiver_wallet_address, :string
    add_column :invoices, :payment_timestamp, :datetime
    add_column :invoices, :transaction_fee, :decimal
    add_column :invoices, :discount_type, :integer
    add_column :invoices, :discount_start_date, :date
    add_column :invoices, :discount_end_date, :date
  end
end
