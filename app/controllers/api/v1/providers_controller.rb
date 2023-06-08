class Api::V1::ProvidersController < ApplicationController
	def index
		render json: Provider.all
	end
end