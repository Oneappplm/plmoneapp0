class AddCertificationToRvaInformations < ActiveRecord::Migration[7.0]
  def change
    add_reference :rva_informations, :certification, foreign_key: true
  end
end
