class AddFullScheduleToProviderDeas < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_deas, :full_schedule, :string
  end
end
