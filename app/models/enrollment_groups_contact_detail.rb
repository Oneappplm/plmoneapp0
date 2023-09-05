class EnrollmentGroupsContactDetail < ApplicationRecord
  belongs_to :enrollment_group

  after_create :send_welcome_letter

  def send_welcome_letter
    return unless self.group_personnel_email.present? && self.enrollment_group.welcome_letter_status

    attachments = []

    if enrollment_group.welcome_letter_attachments.present?
      attachments = enrollment_group.welcome_letter_attachments.map{|a| a.url}
    end

    PlmMailer.with(
      email: group_personnel_email,
      subject: enrollment_group.welcome_letter_subject,
      body: enrollment_group.welcome_letter_message,
      attachments: attachments
    ).welcome_letter.deliver_later
  end
end