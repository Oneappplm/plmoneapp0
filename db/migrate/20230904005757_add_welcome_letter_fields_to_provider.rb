class AddWelcomeLetterFieldsToProvider < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :welcome_letter_status, :boolean, default: false
    add_column :providers, :welcome_letter_subject, :string
    add_column :providers, :welcome_letter_message, :text
    add_column :providers, :welcome_letter_attachments, :json
  end
end
