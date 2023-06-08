class Api::V1::EnrollmentProvidersController < ApplicationController
	def index
		render json: EnrollmentProvider.all
	end
end