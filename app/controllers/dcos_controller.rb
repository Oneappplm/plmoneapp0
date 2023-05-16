class DcosController < ApplicationController
	before_action :set_group
	before_action :set_dco, only: [:edit, :update, :destroy, :show]
	before_action :set_states, only: [:new, :edit, :create, :update]
  before_action :set_dcos, only: [:index, :show]

	def index
	end

	def new
		@dco = @enrollment_group.dcos.new
		@dco.schedules.build
		@dco.provider_outreach_info.build
	end

	def edit
		@dco.schedules.build
		@dco.provider_outreach_info.build
	end

	def create
		@dco = @enrollment_group.dcos.new(dco_params)
		if @dco.save
			redirect_to group_dcos_path(@enrollment_group), notice: 'DCO has been successfully created.'
		else
			render :new
		end
	end

	def update
		if @dco.update(dco_params)
			redirect_to group_dcos_path(@enrollment_group), notice: 'DCO has been successfully updated.'
		else
			render :edit
		end
	end

	def destroy
		if @dco.destroy
			redirect_to group_dcos_path(@enrollment_group), notice: 'DCO has been successfully deleted.'
		else
			redirect_to group_dcos_path(@enrollment_group), alert: 'Something went wrong.'
		end
	end

	protected
	def dco_params
		params.require(:group_dco).permit(
			:client, :dco_name, :dco_address,
			:dco_city, :state, :dco_zipcode, :county,
			:service_location_phone_number, :service_location_fax_number,
			:panel_status_to_new_patients, :panel_age_limit, :include_in_directory,
			:dco_provider_name, :dco_provider_email, :dco_provider_phone_number,
			:dco_provider_fax_number, :dco_provider_position, :inpatient_facility, :is_clinic, :telehealth_provider,
			schedules_attributes: [:id, :day, :start_time, :end_time, :_destroy],
			provider_outreach_info_attributes: [:id, :name, :email, :phone, :fax, :position, :_destroy]
		)
	end

	def set_dco
		@dco = @enrollment_group.dcos.find(params[:id])
	end

	def set_group
		@enrollment_group = EnrollmentGroup.find(params[:group_id])
	end

	def set_states
		@states = State.all
	end

  def set_dcos
    @dcos = if params[:dco_search].present?
      @enrollment_group.dcos.search(params[:dco_search]).paginate(per_page: 10, page: params[:page] || 1)
    else
      @enrollment_group.dcos.paginate(per_page: 10, page: params[:page] || 1)
    end
  end
end