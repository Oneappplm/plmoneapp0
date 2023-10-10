class CreatePractitioners < ActiveRecord::Migration[7.0]
  def change
    create_table :practitioners do |t|

      t.timestamps
    end
  end
end
