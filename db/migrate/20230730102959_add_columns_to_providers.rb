class AddColumnsToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :license_state_number, :string
    add_column :providers, :license_state_effective_date, :string
    add_column :providers, :license_state_id, :string
    add_column :providers, :license_state_expiration_date, :string
  end
end
