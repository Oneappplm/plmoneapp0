class ChangeProvidersStateColumn < ActiveRecord::Migration[7.0]
  def self.up
    change_column :providers, :state, :integer, using: 'state::integer'
  end

  def self.down
    change_column :providers, :state, :string
  end
end
