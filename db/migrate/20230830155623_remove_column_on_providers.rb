class RemoveColumnOnProviders < ActiveRecord::Migration[7.0]
  def down
    remove_column :providers, :send_welcome_letter, :date
  end
end
