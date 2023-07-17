class UsersController < ApplicationController
  	# layout "application", only: %i[new edit show all_users organization_users]
 before_action :get_states, only: %i[edit create new show all_users organization_profile ]
	before_action :set_user, only: %i[edit update show]

	def index
		@user = User.new
		initialize_users
	end

	def edit
		initialize_users
		render 'index'
	end

	def create

		@user = User.new(user_params)
		@user.temporary_password = user_params[:password]
		@user.temporary_password_confirmation = user_params[:password_confirmation]

		if @user.save
			redirect_to users_path, notice: 'User has been successfully created.'
		else
			render :new
		end
	end

	def new
		# render json: params and return
	end

	def update
		if @user.update(user_params)
			redirect_to users_path, notice: 'User has been successfully updated.'
		else
			render :edit
		end
	end

	def destroy
		@user = User.find(params[:id])
		if @user.destroy
			redirect_to users_path, notice: 'User has been successfully deleted.'
		else
			redirect_to users_path, alert: 'Something went wrong.'
		end
	end

	def organization_profile;end

	def show;end

	def organization_users
	end

	def initialize_users
		@users = if params[:user_search].present?
			User.search(params[:user_search]).paginate(per_page: 10, page: params[:page] || 1)
		else
			User.paginate(per_page: 10, page: params[:page] || 1)
		end
	end

	private

  def get_states
  	@states = State.all
  end

		def user_params
			params.require(:user).permit(
				:first_name, :middle_name, :last_name, :suffix,
				:email, :password, :password_confirmation,
				:following_request, :user_type, :status, :user_role,
				:temporary_password, :temporary_password_confirmation, :title
			)
		end

		def set_user
			@user = User.find(params[:id])
		end
end