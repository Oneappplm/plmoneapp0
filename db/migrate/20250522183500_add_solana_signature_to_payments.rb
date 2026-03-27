class AddSolanaSignatureToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :solana_signature, :string
  end
end
