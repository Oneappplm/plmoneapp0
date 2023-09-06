class ApplicationMailer < ActionMailer::Base
  default from: Figaro.env.smtp_email
  layout "mailer"

  protected
  def from
    "PLM Health One App <#{Figaro.env.smtp_email}>"
  end
end
