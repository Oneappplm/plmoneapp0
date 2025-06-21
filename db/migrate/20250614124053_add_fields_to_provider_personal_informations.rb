class AddFieldsToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    change_table :provider_personal_informations do |t|
      t.string :degree_titles
      t.string :state_of_practice, array: true, default: []
      t.string :primary_practioner_type, array: true, default: []
      t.string :other_name
      t.string :country
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :county
      t.string :ps_state
      t.string :zipcode
      t.string :telephone
      t.string :fax_number
      t.boolean :unlisted_number
      t.string :mobile_number
      t.string :page_number
      t.string :ext
      t.string :name_type
      t.date   :date_started
      t.date   :date_stopped
      t.boolean :in_use, default: false
    end
  end
end
