class Api::V1::DcosController < Api::V1::BaseController
	def index
		render json: GroupDco.all
	end
end