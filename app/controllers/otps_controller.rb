class OtpsController < ActionController::Base
	layout	'authentication'
	def request_opt_code
		@otp_token	= params[:id]
		@user 					= User.find_by(otp_token: @otp_token)
		if @user.present? && @user.expired_otp_code?
			@user.reset_opt
			redirect_to	new_user_session_path, alert: "OTP Code expired. Please try again." and return
		elsif request.post?
			otp_code = params[:otp_code]
			otp_token	= params[:otp_token]
			user = User.find_by(otp_token: otp_token)
			if user.present? && user.valid_otp?(otp_code)
				sign_in(user)
				user.reset_opt
				redirect_to root_path, notice: 'Signed in successfully.' and return
			else
				redirect_to 	request_opt_code_otp_path(otp_token), alert: "Invalid OTP Code. Please try again." and return
			end

		end
	end
end
