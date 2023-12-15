class CreatePayorNames < ActiveRecord::Migration[7.0]
  def change
    create_table :payor_names do |t|
      t.string :title

      t.timestamps
    end
  end
end
