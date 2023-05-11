class EnrollmentsController < ApplicationController
	before_action :set_enrollment_group, only: [:edit_group, :delete_group]
	before_action :get_states, only: %i[client_search client_portal virtual_review_committee provider_source all_clients new_dco new_group data_access edit_group]
	before_action :get_provider_types, only: %i[client_search client_portal virtual_review_committee provider_source provider_enrollment new_group data_access edit_group]
	before_action :set_pagination_params, only: [:new_user, :edit_user]
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

	#GROUP
	def groups
		@enrollment_groups = EnrollmentGroup.all
		render "enrollments/groups/index"
	end

	def new_group
		if request.post?
			@enrollment_group = EnrollmentGroup.new(group_params)
			# render json: params and return
			if @enrollment_group.save
				redirect_to groups_enrollments_path, notice: 'Group has been successfully created.' and return
			end
		else
			@enrollment_group = EnrollmentGroup.new
		end
	end

	def edit_group
		@enrollment_group = EnrollmentGroup.find params[:id]

		if	request.patch?
			if @enrollment_group.update(group_params)
				redirect_to groups_enrollments_path, notice: "#{@enrollment_group.group_name} has been successfully updated." and return
			end
		end
		render 'new_group'
	end

	def delete_group
		if @enrollment_group.destroy
			redirect_to groups_enrollments_path, notice: "#{@enrollment_group.group_name} has been deleted."
		else
			redirect_to groups_enrollments_path, alert: 'Something went wrong'
		end
	end

	protected

		def set_enrollment_group
			@enrollment_group = EnrollmentGroup.find(params[:id])
		end

		def get_states
			@states = State.all
		end

		def get_provider_types
			@provider_types = ProviderType.all
		end

		def user_params
			params.require(:user).permit(
				:first_name, :middle_name, :last_name, :suffix,
				:email, :password, :password_confirmation,
				:following_request, :user_type, :status
			)
		end

		def group_params
			params.require(:enrollment_group).permit(
				 :group_name,
				 :group_code,
				 :office_address,
				 :city,
				 :state,
				 :zip_code,
				 :phone_number,
				 :ext,
				 :fax_number,
				 :business_group,
				 :legal_business_name,
				 :another_business_name,
				 :other_business_name,
			   :other_business_type,
				 :specify_type_of_group,
				 :shared_tin,
				 :tin_file,
				 :specify_type_of_group_file,
				 :npi_digit_type,
			   :provider_type,
				 :po_box,
				 :po_box_city,
				 :po_box_state,
				 :po_box_zip_code,
				 :ca_po_box_address,
				 :ca_po_box_city,
				 :ca_po_box_state,
				 :ca_po_box_zip_code,
				 :individual_ownership,
					:tin_digit,
					:tin_digit_irs,
					:w9_file,
					:cp575_file,
					:specific_type_file,
					:ownership_file,
					:npi_digit_type_group,
			)
		end

		def set_pagination_params
			@per_page = params[:per_page] || 100
			@page = params[:page] || 1
		end
end