class EnrollmentGroupsContactDetail < ApplicationRecord
  belongs_to :enrollment_group

  after_create :send_welcome_letter

  def send_welcome_letter
    return unless self.group_personnel_email.present?

    PlmMailer.with(email: self.group_personnel_email, attachments: ['welcome-letter-new-group.docx', 'welcome-letter-new-group.xlsx']).welcome_letter.deliver_later
  end
end