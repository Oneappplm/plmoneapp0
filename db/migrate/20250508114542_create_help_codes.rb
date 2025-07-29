class CreateHelpCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :help_codes do |t|

      t.timestamps
    end
  end
end
