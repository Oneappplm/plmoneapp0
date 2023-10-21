class CreateProviderSourceTeachingPrograms < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_source_teaching_programs do |t|
      t.integer :provider_source_id
      t.string :location
      t.string :name
      t.string :address1
      t.string :address2
      t.string :city
      t.string :zip_code
      t.string :phone_number
      t.string :phone_ext
      t.string :fax_number
      t.string :email
      t.string :director_first_name
      t.string :director_last_name
      t.string :director_degree
      t.string :academic_rank
      t.boolean :not_expire
      t.datetime :start_date
      t.datetime :end_date
      t.timestamps
    end
  end
end
