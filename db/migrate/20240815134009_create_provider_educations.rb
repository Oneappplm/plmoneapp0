class CreateProviderEducations < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_educations, id: false do |t|
      t.primary_key    :provider_education_id
      t.references     :provider_attest
      t.string         :institution_name
      t.string         :address
      t.string         :address2
      t.string         :city
      t.string         :province
      t.string         :state
      t.string         :postal_code
      t.datetime       :start_date
      t.datetime       :end_date
      t.string         :affiliated_university_name
      t.string         :hospital_department_name
      t.string         :training_area
      t.string         :email_address
      t.string         :certificate_issued_by
      t.string         :program_title
      t.boolean        :apa_approved_flag
      t.boolean        :program_completed_flag
      t.string         :program_director
      t.datetime       :completion_date
      t.string         :certificate_awarded
      t.string         :teaching_position
      t.string         :current_program_director
      t.text           :incomplete_explanation
      t.string         :phone_number
      t.string         :fax_number
      t.boolean        :disciplinary_action_flag
      t.text           :disciplinary_action_explanation
      t.string         :program_director_degree
      t.string         :program_type
      t.text           :additional_training_description
      t.string         :education_type_name
      t.string         :hours
      t.string         :country_country_name
      t.string         :degree_degree_abbreviation
      t.string         :specialty_specialty_name
      t.text           :institution_type_institution_type_description

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_educations
  end
end
