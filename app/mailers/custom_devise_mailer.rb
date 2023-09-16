class CustomDeviseMailer < Devise::Mailer
	def invitation_instructions(record, token, opts = {})
			@token = token
			email_cc = record.email_cc
			subject = record.email_subject || 'Invitation Instructions'

			devise_mail(record, :invitation_instructions, opts) do |format|
					format.text
					format.html

					if email_cc.present?
						headers['Cc'] = email_cc
					end

					headers['Subject'] = subject

			end
	end

	# def reset_password_instructions(record, token, opts = {})
	# 	attachments.inline['logo.png'] = File.read(File.join(Rails.root, 'public', 'logos', 'qualifacts-logo.png'))
	# 	super
	# end
end