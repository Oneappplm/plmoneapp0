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

		mail(to: @email, from: from, subject: Setting.take.t('mailers.plm_mailer.subject'))
	end

	def welcome_letter
		@email = params[:email]
		file_attachments = params[:attachments]
		subject	= params[:subject] || "Request for Credentialing Documentation"
		@message	= params[:body]
		cc	= params[:cc]

		file_attachments.each do |filename|
			if filename.include? "https"
				attachments.inline[filename] = open(URI.open(filename)).read
			else
				if params[:folder_name].present?
					attachments.inline[filename] = File.read(File.join(Rails.root, 'lib', 'data', 'attachments', params[:folder_name], filename))
				else
					attachments.inline[filename] = File.read(File.join(Rails.root, 'lib', 'data', 'attachments', filename))
				end
			end
		end

		#  add logo
  attachments.inline['logo.png'] = File.read(File.join(Rails.root, 'public', 'logos', 'qualifacts-logo.png'))

		mail(to: @email, from: from, subject: subject, cc: cc)
	end

	def send_invite_and_reset_password_instructions
		@user = params.dig(:user)
		@token = params.dig(:token)
		@email = params.dig(:params, :email_to)
		email_cc = params.dig(:params, :email_cc)
		subject = params.dig(:params, :subject) || 'Invitation Instructions'
		@message = params.dig(:params, :message)

		mail(to: @email, from: from, subject: subject, cc: email_cc)
	end

	def send_system_notification
		@email = params[:email]
		subject	= params[:subject]
		@message	= params[:body]

		mail(to: @email, from: from, subject: subject)
	end
end