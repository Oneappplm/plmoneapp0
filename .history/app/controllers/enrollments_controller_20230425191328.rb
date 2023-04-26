class EnrollmentsController < ApplicationController
	before_action :set_pagination_params, only: [:new_user, :edit_user, :new_group, :edit_enrollment_group]

	def index
		@enrollment_group = Group.all
	end

	# USER
	def new_user
		if request.post?
			@enrollment_user = User.new(user_params)
			@enrollment_user.from_source = 'enrollment'
			if @enrollment_user.save
				redirect_to new_user_enrollments_path, notice: "#{@enrollment_user.full_name} has been successfully created." and return
			end
		else
			@enrollment_user = User.new
		end

		@enrollment_users = if params[:user_search].present?
			User.where(from_source: 'enrollment').search(params[:user_search]).paginate(per_page: 10, page: params[:page] || 1)
		else
			User.where(from_source: 'enrollment').paginate(per_page: 10, page: params[:page] || 1)
		end
	end

	def edit_user
		@enrollment_user = User.find params[:id]
		if	request.patch?
			if @enrollment_user.update(user_params)

				redirect_to new_user_enrollments_path, notice: "#{@enrollment_user.full_name} has been successfully updated." and return
			end
		end
		@enrollment_users = User.where(from_source: 'enrollment').paginate(per_page: 10, page: params[:page] || 1)
		render 'new_user'
	end

	def delete_user
		user = User.find params[:id]
		if user.destroy
			redirect_to new_user_enrollments_path, notice: "#{user.full_name} has been deleted."
		else
				redirect_to new_user_enrollments_path, alert: 'Something went wrong'
		end
	end

	# GROUP CRUD
	def new_group
		if request.post?
			@enrollment_group = Group.new(group_params)
			if @enrollment_group.save
				redirect_to new_group_enrollments_path, notice: 'Group has been successfully created.' and return
			end
		else
			@enrollment_group = Group.new
		end
	end

	def edit_enrollment_group
		@enrollment_group = EnrollmentGroup.find params[:id]
		if	request.patch?
			if @enrollment_group.update(group_params)

				redirect_to new_group_enrollments_path, notice: "#{enrollment_group.name} has been successfully updated." and return
			end
		end
		@enrollment_group = Group.where(from_source: 'enrollment').paginate(per_page: 10, page: params[:page] || 1)
		render 'new_group'
	end

	def delete_enrollment_group
		user = EnrollmentGroup.find params[:id]
		if user.destroy
			redirect_to new_group_enrollments_path, notice: "#{@enrollment_group.name} has been deleted."
		else
			redirect_to new_group_enrollments_path, alert: 'Something went wrong'
		end
	end

	protected
		def user_params
			params.require(:user).permit(
				:first_name, :middle_name, :last_name, :suffix,
				:email, :password, :password_confirmation,
				:following_request, :user_type, :status
			)
		end

		def group_params
			params.require(:group).permit(
				:name, :email, :phone, :fax, :address, :city, :state, :zip, :status
			)
		end

		def set_pagination_params
			@per_page = params[:per_page] || 100
			@page = params[:page] || 1
		end
end