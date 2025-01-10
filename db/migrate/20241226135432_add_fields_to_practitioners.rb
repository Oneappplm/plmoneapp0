class AddFieldsToPractitioners < ActiveRecord::Migration[7.0]
  def change
    add_column :practitioners, :first_name_of_credentialing_contact, :string
    add_column :practitioners, :middle_name_of_credentialing_contact, :string
    add_column :practitioners, :last_name_of_credentialing_contact, :string
    add_column :practitioners, :suffix_of_credentialing_contact, :string
  end
end
