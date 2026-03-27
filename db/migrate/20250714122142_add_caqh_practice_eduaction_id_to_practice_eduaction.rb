class AddCaqhPracticeEduactionIdToPracticeEduaction < ActiveRecord::Migration[7.0]
  def change
    add_column :practice_information_educations, :caqh_practice_information_education_id, :integer
  end
end
