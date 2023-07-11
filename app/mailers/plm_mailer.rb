class PlmMailer < ApplicationMailer
	def test_message
		@email = params[:email]
		mail(to: @email, from: from, subject: "Test Message")
	end

	def send_notification_timeline
		email = params[:email]
		@timeline = ProvidersTimeLine.find(params[:timeline_id])
		@provider = @timeline.provider

		mail(to: email, from: from, subject: @timeline.title)
	end
end