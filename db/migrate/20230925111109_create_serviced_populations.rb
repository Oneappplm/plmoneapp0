class CreateServicedPopulations < ActiveRecord::Migration[7.0]
  def change
    create_table :serviced_populations do |t|
      t.string :name
      t.timestamps
    end
  end
end
