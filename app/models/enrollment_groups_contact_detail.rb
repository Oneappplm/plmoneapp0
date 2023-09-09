class EnrollmentGroupsContactDetail < ApplicationRecord
  belongs_to :enrollment_group

  after_create :send_welcome_letter

  def send_welcome_letter
    return unless self.group_personnel_email.present? && self.enrollment_group.welcome_letter_status

    attachments = []

    if enrollment_group.welcome_letter_attachments.present?
      attachments = enrollment_group.welcome_letter_attachments.map{|a| a.url}
    end

    attachments << "Welcome Letter New Group vs4_Rebranded.docx" if enrollment_group.check_welcome_letter
    attachments << "CO CAQH Authorization-Attestation and Release Forms.pdf" if enrollment_group.check_co_caqh
    attachments << "MN CAQH State Release Form.pdf" if enrollment_group.check_mn_caqh_state_release_form
    attachments << "MN CAQH Authorization Form.pdf" if enrollment_group.check_mn_caqh_authorization_form
    attachments << "CAQH Standard Authorization.pdf" if enrollment_group.check_caqh_standard_authorization

    PlmMailer.with(
      email: group_personnel_email,
      subject: enrollment_group.welcome_letter_subject,
      body: enrollment_group.welcome_letter_message,
      attachments: attachments,
      folder_name: 'group'
    ).welcome_letter.deliver_later
  end
end