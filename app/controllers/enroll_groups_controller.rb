class EnrollGroupsController < ApplicationController
	before_action :set_enroll_group, only: [:edit, :update, :destroy]

	def index
		@enroll_groups = if params[:enroll_group_search].present?
			EnrollGroup.search(params[:enroll_group_search]).paginate(per_page: 10, page: params[:page] || 1)
		else
			EnrollGroup.all.paginate(per_page: 10, page: params[:page] || 1)
		end
	end

	def new
		@enroll_group = EnrollGroup.new
	end

	def edit; end

	def create
		@enroll_group = EnrollGroup.new(enroll_group_params)
		if @enroll_group.save
			redirect_to enroll_groups_path, notice: 'Enrollment Group has been successfully created.'
		else
			render 'new'
		end
	end

	def update
		if @enroll_group.update(enroll_group_params)
			redirect_to enroll_groups_path, notice: 'Enrollment Group has been successfully updated.'
		else
			render 'edit'
		end
	end

	def destroy
		if @enroll_group.destroy
			redirect_to enroll_groups_path, notice: 'Enrollment Group has been successfully deleted.'
		else
			redirect_to enroll_groups_path, alert: 'Something went wrong'
		end
	end

	protected
	def set_enroll_group
		@enroll_group = EnrollGroup.find(params[:id])
	end

	def enroll_group_params
		params.require(:enroll_group).permit(
					:name,
					:first_name,
					:middle_name,
					:last_name,
					:suffix,
					:email,
					:telephone_number,
					:medicare_ptan,
					:medicaid_group_number,
					:bcbs_number,
					:tricate_military,
					:commercial_name,
	 				:contracted,
					:revalidated,
					:revalidated_payer_name,
					:application_contracts,
					:application_payer_name,
					:with_medicare,
					:with_eft,
					:with_edi,
					:start_date,
					:due_date,
					:payer,
					:revalidation_date,
					:enrollment_type,
					:status,
					:group_id,
					:user_id,
					:outreach_type,
					:enrollment_payer
	)
	end
end