class AddPayerLoginToProviders < ActiveRecord::Migration[7.0]
  def up
    add_column :providers, :payer_login, :string, default: 'no'
  end

  def down
    remove_column :providers, :payer_login, :string, default: 'no'
  end
end
