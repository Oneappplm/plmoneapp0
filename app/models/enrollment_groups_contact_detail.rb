class EnrollmentGroupsContactDetail < ApplicationRecord
  belongs_to :enrollment_group

  after_create :send_welcome_letter

  def send_welcome_letter
    return unless self.group_personnel_email.present?

    PlmMailer.with(email: self.group_personnel_email, filename: 'welcome-letter-new-group-v2.docx').welcome_letter.deliver_later
  end
end