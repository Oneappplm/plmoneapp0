class AddFieldsToHelpCodes < ActiveRecord::Migration[7.0]
  def change
    add_column :help_codes, :category, :string
    add_column :help_codes, :code, :string
    add_column :help_codes, :description, :string
  end
end
