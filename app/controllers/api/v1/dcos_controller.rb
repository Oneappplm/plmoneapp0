class Api::V1::DcosController < ApplicationController
	def index
		render json: GroupDco.all
	end
end