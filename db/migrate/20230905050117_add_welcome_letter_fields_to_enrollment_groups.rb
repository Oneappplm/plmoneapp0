class AddWelcomeLetterFieldsToEnrollmentGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_groups, :welcome_letter_status, :boolean, default: false
    add_column :enrollment_groups, :welcome_letter_subject, :string
    add_column :enrollment_groups, :welcome_letter_message, :text
    add_column :enrollment_groups, :welcome_letter_attachments, :json
  end
end
