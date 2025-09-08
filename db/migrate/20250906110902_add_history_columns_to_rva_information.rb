class AddHistoryColumnsToRvaInformation < ActiveRecord::Migration[7.0]
  def change
    add_column :rva_informations, :liability_coverage, :boolean
    add_column :rva_informations, :professional_liability, :boolean
  end
end
