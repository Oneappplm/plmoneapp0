class UsersController < ApplicationController
	# layout "application", only: %i[new edit show all_users organization_users]
	before_action :get_states, only: %i[edit create new show all_users organization_profile]
	before_action :set_user, only: %i[edit update show]
	before_action :set_groups, only: %i[edit create new show all_users organization_profile index update]

	def index
		@user = User.new
		initialize_users
	end

	def edit
		initialize_users
		render 'index'
	end

	def create
		initialize_users
		enrollment_group_ids = user_params.delete(:enrollment_group_ids)&.split(",")
		updated_params = user_params.except(:enrollment_group_ids)
		if enrollment_group_ids.present? && enrollment_group_ids.length > 0
			users_enrollment_group_attributes = enrollment_group_ids.map { |id| { enrollment_group_id: id, _destroy: false }}
			updated_params = user_params.merge!({ users_enrollment_groups_attributes: users_enrollment_group_attributes })
		end
		@user = User.where(email: updated_params[:email]).first_or_initialize(updated_params.except(:enrollment_group_ids))
		if @user.persisted?
			@user = User.new(updated_params.except(:enrollment_group_ids))
			@user.errors.add(:base, 'Invalid account')
			render :index and return
		end

		if @user.save
			redirect_to users_path, notice: 'User has been successfully created.'
		else
			render :index
		end
	end

	def new
		# render json: params and return
	end

	def update
		enrollment_group_ids = user_params.delete(:enrollment_group_ids)&.split(",")&.map(&:to_i)
		updated_params = user_params
		if enrollment_group_ids.present? && enrollment_group_ids.length > 0
			# remove unchecked enrollment_groups
			@user.users_enrollment_groups.where.not(enrollment_group_id: enrollment_group_ids).destroy_all
			existing_enrollment_group_ids = @user.users_enrollment_groups&.pluck(:enrollment_group_id)
			add_enrollment_groups_ids = enrollment_group_ids - existing_enrollment_group_ids
			users_enrollment_group_attributes = add_enrollment_groups_ids.map { |id| { enrollment_group_id: id, _destroy: false }}
			if users_enrollment_group_attributes.present?
				updated_params = updated_params.merge!({ users_enrollment_groups_attributes: users_enrollment_group_attributes })
			end
		else
			@user.users_enrollment_groups.destroy_all
		end

		@user.accessible_provider = nil if user_params[:is_provider_account] == "false"

		if @user.update(updated_params.except(:enrollment_group_ids))
			redirect_to users_path, notice: 'User has been successfully updated.'
		else
			render :index
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

	def set_groups
		if current_user.can_access_all_groups? || current_user.super_administrator? || current_admin
      @enrollment_groups = EnrollmentGroup.all
    else
      @enrollment_groups = current_user.enrollment_groups
    end
	end

	def user_params
		params.require(:user).permit(
			:first_name, :middle_name, :last_name, :suffix, :can_access_all_groups,
			:enrollment_group_id, :email, :password, :password_confirmation,
			:following_request, :user_type, :status, :user_role,
			:temporary_password, :temporary_password_confirmation, :title,
			:enrollment_group_ids, :accessible_provider, :is_provider_account, :hidden_role,
			:assigned_access_only
		)
	end

	def set_user
		@user = User.find(params[:id])
	end
end
