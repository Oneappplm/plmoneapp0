class RemoveClientIdFromProviders < ActiveRecord::Migration[7.0]
  def change
    remove_reference :providers, :client, foreign_key: true
  end
end
