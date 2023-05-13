class AddNameAdmittingPhysicianToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :name_admitting_physician, :string
  end
end
