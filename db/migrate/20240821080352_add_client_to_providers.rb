class AddClientToProviders < ActiveRecord::Migration[7.0]
  def change
    add_reference :providers, :client, foreign_key: true
  end
end
