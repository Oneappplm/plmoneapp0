class CreateHelpCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :help_codes, if_not_exists: true do |t|
      t.string :category
      t.string :code
      t.string :description

      t.timestamps
    end
  end
end
