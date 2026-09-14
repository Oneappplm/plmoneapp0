class AddScheduledHeldFieldToProviderDea < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_deas, :schedules_held, :string
  end
end
