class CreateHealthPlans < ActiveRecord::Migration[7.0]
  def change
    create_table :health_plans do |t|
      t.string :name
      
      t.timestamps
    end
  end
end
