class ApplicationMailer < ActionMailer::Base
  default from: "plmhealthoneapp@gmail.com"
  layout "mailer"

  protected
  def from
    "PLM Health One App <plmhealthoneapp@gmail.com>"
  end
end
