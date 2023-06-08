class Api::V1::GroupsController < ApplicationController
	def index
		render json: EnrollmentGroup.all
	end
end