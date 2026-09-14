class CreateGraduateDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :graduate_details do |t|
      t.references :provider_source, null: false, foreign_key: true

      t.string :education_type
      t.string :location
      t.string :professional_school_name

      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :zip_code
      t.string :telephone_number
      t.string :telephone_ext
      t.string :fax_number
      t.string :email

      t.string :graduate_type
      t.string :specialization
      t.string :degree_awarded

      t.string :faculty_director_first_name
      t.string :faculty_director_last_name
      t.string :director_degree

      t.date :start_date
      t.date :graduation_date

      t.string :incomplete_education_reason
      t.boolean :education_completed, default: true

      # ECFMG Fields
      t.boolean :ecfmg_certified
      t.string :ecfmg_number
      t.date :ecfmg_issue_date
      t.date :ecfmg_valid_through
      t.boolean :ecfmg_permanent

      t.timestamps
    end
  end
end
