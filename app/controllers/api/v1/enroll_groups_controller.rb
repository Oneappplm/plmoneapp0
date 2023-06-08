class Api::V1::EnrollGroupsController < ApplicationController
	def index
		render json: EnrollGroup.all
	end
end