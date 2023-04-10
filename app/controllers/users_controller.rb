class UsersController < ApplicationController
  	# layout "application", only: %i[new edit show all_users organization_users]
  before_action :get_states, only: %i[edit new show all_users organization_profile]

	def new
		# render json: params and return
	end

	def edit;end

	def update;end

	def organization_profile;end

	def show;end

	def organization_users
	end

	private

  def get_states
  	@states = State.all
  end
end