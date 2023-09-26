class AddNewPayerLoginToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :payer_login, :string, default: 'no', if_not_exists: true
  end
end
