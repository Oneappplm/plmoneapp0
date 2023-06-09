class Api::V1::EnrollmentProvidersController < Api::V1::BaseController
	def index
		render json: EnrollmentProvider.all
	end
end