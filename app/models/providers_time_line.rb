class ProvidersTimeLine < ApplicationRecord
  belongs_to :provider
  after_create :notify_provider

  def notify_provider
    return unless provider.present? && provider.email_address.present?

    PlmMailer.with(email: provider.email_address, timeline_id: self.id).send_notification_timeline.deliver_now
  end
end