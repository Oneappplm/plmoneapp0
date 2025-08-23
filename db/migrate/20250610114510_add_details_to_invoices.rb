class AddDetailsToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :invoice_number, :string
    add_column :invoices, :clinic_name, :string
    add_column :invoices, :date_of_service, :date
    add_column :invoices, :service_description, :text
    add_column :invoices, :tax, :decimal, precision: 10, scale: 2
    add_column :invoices, :medv_token_amount, :decimal, precision: 10, scale: 2
    add_column :invoices, :due_date, :date
    add_column :invoices, :payment_confirmation_status, :boolean, default: false
  end
end
