class Api::V1::GroupsController < Api::V1::BaseController
	def index
		render json: EnrollmentGroup.all
	end
end