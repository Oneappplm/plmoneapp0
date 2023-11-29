class AddColumnPayerLoginIfNotExists < ActiveRecord::Migration[7.0]
  def change
				unless column_exists?(:providers, :payer_login)
						add_column :providers, :payer_login, :string, default: 'no'
				end
  end
end
