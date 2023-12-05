class UserVisitsController < ApplicationController
	before_action :initialize_visits, only: [:index]
	def index; end

	protected
	def initialize_visits
		@visits = Ahoy::Visit.includes(:events, :user).references(:user).paginate(per_page: 50, page: params[:page] || 1)
	end
end
