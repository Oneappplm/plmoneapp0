class AddAdditionalFieldsToPracticeInformationEducations < ActiveRecord::Migration[7.0]
  def change
    add_column :practice_information_educations, :suite_dept_mail_stop, :string
    add_column :practice_information_educations, :if_other_list, :string
    add_column :practice_information_educations, :comments, :text
    add_column :practice_information_educations, :show_on_tickler, :boolean, default: false
  end
end
