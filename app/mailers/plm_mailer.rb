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

	def welcome_letter
		email = params[:email]
		attachments.inline['welcome-letter-new-provider-v1.docx'] = File.read(File.join(Rails.root,'lib','data','attachments','welcome-letter-new-provider-v1.docx'))
		mail(to: email, from: from, subject: "PLM Health’s One App Greetings")
	end
end