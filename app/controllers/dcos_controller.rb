class DcosController < ApplicationController
	before_action :set_group
	before_action :set_dco, only: [:edit, :update, :destroy, :show]
	before_action :set_states, only: [:new, :edit, :create, :update]
  before_action :set_dcos, only: [:index, :show]

	def index
	end

	def new
		@dco = @enrollment_group.dcos.new
		@dco.schedules.build if !@dco.schedules.present?
		@dco.provider_outreach_info.build if !@dco.provider_outreach_info.present?
		@dco.old_location_addresses.build if !@dco.old_location_addresses.present?
	end

	def edit
		@dco.schedules.build if !@dco.schedules.present?
		@dco.provider_outreach_info.build if !@dco.provider_outreach_info.present?
		@dco.old_location_addresses.build if !@dco.old_location_addresses.present?
	end

	def create
		@dco = @enrollment_group.dcos.new(dco_params)
		if @dco.save
			PlmMailer.with(
				email: Setting.take.t('system_notification_email'),
				subject: "Add Location",
				body: "#{current_user&.full_name} added a new location: #{@dco&.dco_name}"
			).send_system_notification.deliver_later
			redirect_to group_dcos_path(@enrollment_group), notice: 'DCO has been successfully created.'
		else
			@dco.schedules.build if !@dco.schedules.present?
			@dco.provider_outreach_info.build if !@dco.provider_outreach_info.present?
			render :new
		end
	end

	def update
		if @dco.update(dco_params)
			PlmMailer.with(
				email: Setting.take.t('system_notification_email'),
				subject: "Edit Location",
				body: "#{current_user&.full_name} edited a location: #{@dco&.dco_name}"
			).send_system_notification.deliver_later
			redirect_to group_dcos_path(@enrollment_group), notice: 'DCO has been successfully updated.'
		else
			@dco.schedules.build if !@dco.schedules.present?
			@dco.provider_outreach_info.build if !@dco.provider_outreach_info.present?
			render :edit
		end
	end

	def destroy
		if @dco.destroy
			PlmMailer.with(
				email: Setting.take.t('system_notification_email'),
				subject: "Delete Location",
				body: "#{current_user&.full_name} deleted a location: #{@dco&.dco_name}"
			).send_system_notification.deliver_later
			redirect_to group_dcos_path(@enrollment_group), notice: 'DCO has been successfully deleted.'
		else
			redirect_to group_dcos_path(@enrollment_group), alert: 'Something went wrong.'
		end
	end

	protected
	def dco_params
		params.require(:group_dco).permit(
			:client, :dco_name, :dco_address, :effective_date, :npi_digits, :tin_digits_type,
			:dco_city, :state, :dco_zipcode, :county, :is_primary_location, :specialty,
			:service_location_phone_number, :service_location_fax_number,
			:panel_status_to_new_patients, :panel_age_limit, :include_in_directory,
			:dco_provider_name, :dco_provider_email, :dco_provider_phone_number,
			:dco_provider_fax_number, :dco_provider_position, :inpatient_facility, :is_clinic,
			:telehealth_provider, :website, :tax_id, :facility_billing_npi, :mn_medicaid_number,
			:wi_medicaid_number, :medicare_id_ptan, :taxonomy, :telehealth_video_conferencing_technology,
			:is_gender_affirming_treatment, :panel_size, :medicare_authorized_official, :collab_npi, :collab_name, :location_status, :location_npi, :location_tin,
			old_location_addresses_attributes: [:id, :old_address, :old_city, :old_state, :old_county, :old_zipcode, :is_old_location_primary, :effective_date, :_destroy],
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
      @enrollment_group.dcos.where("dco_name LIKE ?", "%#{params[:dco_search]}%").order("dco_name ASC").paginate(per_page: 10, page: params[:page] || 1)
    else
      @enrollment_group.dcos.order("dco_name ASC").paginate(per_page: 10, page: params[:page] || 1)
    end
  end
end