class CreateMethodResolutions < ActiveRecord::Migration[7.0]
  def change
    create_table :method_resolutions do |t|
      t.string :name
      t.timestamps
    end
  end
end
