class CreateProviderSourceUndergradSchools < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_source_undergrad_schools do |t|
      t.references :provider_source, null: false, foreign_key: true
      t.string :school_location
      t.string :undergraduate_school_name
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :zipcode
      t.string :telephone_number
      t.string :ext
      t.string :fax_number
      t.string :email
      t.string :degree_awarded
      t.date :date_start
      t.date :date_graduation
      t.boolean :incomplete
      t.text :reason

      t.timestamps
    end
  end
end
