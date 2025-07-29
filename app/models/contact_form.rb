class ContactForm < MailForm::Base
  attributes :name
  attributes :email, validate: /\A[^@\s]+@[^@\s]+\z/i
  attributes :message
  attributes :subject
  attributes :attachments, attachment: true

  def headers
    {
      #this is the subject for the email generated, it can be anything you want
      subject: subject,
      from: from,
      to: email,
      attachment: attachments,
      message: message
      #the from will display the name entered by the user followed by the email
    }
  end

  protected
  def from
    "#{Setting.take.t('mailers.plm_mailer.from')} <#{Figaro.env.smtp_email}>"
  end
end
