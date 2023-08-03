class AddNewColumnToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :end_date, :string
  end
end
