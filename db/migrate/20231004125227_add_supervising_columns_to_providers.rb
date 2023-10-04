class AddSupervisingColumnsToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :supervising_name, :string
    add_column :providers, :supervising_npi, :string
  end

  def down 
    remove_column :providers, :supervising_name_npi, :string
  end
end
