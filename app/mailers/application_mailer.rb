class ApplicationMailer < ActionMailer::Base
  default from: "info@plmhealth.com"
  layout "mailer"

  protected
  def from
    "PLM Health One App <info@plmhealth.com>"
  end
end
