class AddNewCheckboxBoardcertToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :board_certificate_not_applicable, :string
    add_column :providers, :board_cert_explain, :string
    add_column :providers, :board_specialty_type, :string
    add_column :providers, :supervising_name_npi, :string
  end
end
