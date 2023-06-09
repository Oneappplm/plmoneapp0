class Api::V1::BaseController < ActionController::Base
	protect_from_forgery with: :null_session
	before_action :validate_token

	protected

		def bearer_token
			authorization_header = request.headers['Authorization']
			authorization_header.split(' ')[1] if authorization_header
		rescue
			nil
		end

		def validate_token
			if bearer_token.nil? || (bearer_token.present? && User.find_by_token(bearer_token).nil?)
				render json: { errors: 'Unauthorized' }, status: 401
				return
			end
		end
end