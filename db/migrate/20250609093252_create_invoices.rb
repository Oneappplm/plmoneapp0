class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.references :provider, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.references :appointment, null: false, foreign_key: true
      t.string :service_name
      t.decimal :amount
      t.decimal :discount
      t.decimal :total
      t.string :qr_code_url
      t.string :payment_memo
      t.string :payment_method
      t.string :solana_signature
      t.string :status, default: 'unpaid'

      t.timestamps
    end
  end
end
