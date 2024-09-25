class AddFieldsToProvider < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :work_history_not_applicable, :string
    add_column :providers, :work_history_explain, :string
  end
end
