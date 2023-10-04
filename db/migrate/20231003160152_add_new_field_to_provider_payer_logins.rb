class AddNewFieldToProviderPayerLogins < ActiveRecord::Migration[7.0]
  def change
    add_column :providers_payer_logins, :cred_current_reattest_date, :date
    add_column :providers_payer_logins, :cred_reattest_date, :date
  end
end
