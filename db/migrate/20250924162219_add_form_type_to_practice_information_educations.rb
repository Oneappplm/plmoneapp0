class AddFormTypeToPracticeInformationEducations < ActiveRecord::Migration[7.0]
  def change
    add_column :practice_information_educations, :form_type, :string
  end
end
