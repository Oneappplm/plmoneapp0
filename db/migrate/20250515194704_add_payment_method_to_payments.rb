class AddPaymentMethodToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :payment_method, :integer
    add_column :payments, :amount, :decimal
  end
end
