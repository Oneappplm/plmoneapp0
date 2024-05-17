class AddFieldToProvider < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :prof_liability_form, :boolean
  end
end
