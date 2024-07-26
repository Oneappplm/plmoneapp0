class AddUserIdToProviders < ActiveRecord::Migration[7.0]
  def change
    add_reference :providers, :user, foreign_key: true
  end
end
