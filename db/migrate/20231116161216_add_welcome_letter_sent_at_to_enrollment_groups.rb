class AddWelcomeLetterSentAtToEnrollmentGroups < ActiveRecord::Migration[7.0]
  def change
				add_column :enrollment_groups, :welcome_letter_sent_at, :datetime
  end
end
