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

	def send_otp_code_mail
		@email = params[:email]
		@otp_code	= params[:otp_code]

		mail(to: @email, from: from, subject: "PLM Health's One App OTP Code")
	end

	def welcome_letter
		email = params[:email]
		file_attachments = params[:attachments]

		file_attachments.each do |filename|
			attachments.inline[filename] = File.read(File.join(Rails.root, 'lib', 'data', 'attachments', filename))
		end

		mail(to: email, from: from, subject: "PLM Health's One App Greetings")
	end
end