class ApplicationMailer < ActionMailer::Base
  default from: Figaro.env.smtp_email
  layout "mailer"

  protected
  def from
    "#{Setting.take.t('mailers.plm_mailer.from')} <#{Figaro.env.smtp_email}>"
  end
end
