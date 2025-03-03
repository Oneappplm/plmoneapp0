class AddPopulationFieldsToSpecialtyDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :specialty_details, :target_population_privileges, :string
    add_column :specialty_details, :populations_employment_type, :string
    add_column :specialty_details, :populations_served, :string
    add_column :specialty_details, :specialty_student_intern, :boolean
    add_column :specialty_details, :populations_infos, :text
    add_column :specialty_details, :populations_served_text, :text
    add_column :specialty_details, :failed_exam_date, :date
    add_column :specialty_details, :failed_exam_certifying_board, :string
    add_column :specialty_details, :failed_exam_reason, :text
    add_column :specialty_details, :certification_expiry, :date
  end
end
