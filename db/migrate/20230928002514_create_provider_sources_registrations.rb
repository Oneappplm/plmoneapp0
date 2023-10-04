class CreateProviderSourcesRegistrations < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_sources_registrations do |t|
      t.references :provider_source
      t.string :registration_number
      t.string :specialty
      t.string :issue_state
      t.string :issuing_board
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :registration_state
      t.string :zip_code
      t.string :telephone_number
      t.string :ext
      t.string :fax_number
      t.datetime :issue_date
      t.datetime :expiration_date
      t.string :does_not_expire
      t.string :practicing_under_number


      t.timestamps
    end
  end
end
