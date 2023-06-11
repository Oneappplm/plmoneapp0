class PlmMailer < ApplicationMailer
	def test_message
		@email = params[:email]
		mail(to: @email, from: from, subject: "Test Message")
	end
end