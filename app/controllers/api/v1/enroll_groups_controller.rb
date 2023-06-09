class Api::V1::EnrollGroupsController < Api::V1::BaseController
	def index
		render json: EnrollGroup.all
	end
end