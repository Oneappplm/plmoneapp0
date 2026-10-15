class AddExtraFields < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :degree_titles, :string
    add_column :provider_personal_informations, :address_line1, :string
    add_column :provider_personal_informations, :address_line2, :string
    add_column :provider_personal_informations, :city, :string
    add_column :provider_personal_informations, :country, :string
    add_column :provider_personal_informations, :county, :string
    add_column :provider_personal_informations, :fax_number, :string
    add_column :provider_personal_informations, :state, :string
    add_column :provider_personal_informations, :zipcode, :string
    add_column :provider_personal_informations, :telephone_number, :string
    add_column :provider_other_names, :name_type, :string
    add_column :provider_other_names, :in_use, :boolean
  end
end
