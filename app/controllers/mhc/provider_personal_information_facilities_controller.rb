class Mhc::ProviderPersonalInformationFacilitiesController < ApplicationController
  before_action :set_facility, only: [:edit, :show, :update, :destroy]

  def index
    @facilities = ProviderPersonalInformationFacility.all
  end

  def new
    @facility = ProviderPersonalInformationFacility.new
  end

  def create
    @facility = ProviderPersonalInformationFacility.new(facility_params)

    if params[:commit] == "Create"
      @facility.form_type = "main"
    elsif params[:commit] == "Save"
      @facility.form_type = "popup"
    end

    if @facility.save
      redirect_to mhc_verification_platform_path(page_tab: 'facilities',id: params[:provider_personal_information_facility][:provider_attest_id]), notice: 'Facility detail saved successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'add_new_facility',id: params[:provider_personal_information_facility][:provider_attest_id]), alert: 'Failed to save Facility detail.'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @facility.update(facility_params)
      redirect_to mhc_verification_platform_path(page_tab: 'facilities',id: params[:provider_personal_information_facility][:provider_attest_id]), notice: 'Facility detail updated successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'add_new_facility',id: params[:provider_personal_information_facility][:provider_attest_id]), alert: 'Failed to save Facility detail.'
    end
  end

  def destroy
    provider_attest_id = @facility.provider_attest_id

    if @facility.destroy
      redirect_to mhc_verification_platform_path(
        page_tab: 'facilities',
        id: provider_attest_id
      ), notice: 'Facility detail deleted successfully.'
    else
      redirect_to mhc_verification_platform_path(
        page_tab: 'add_new_facility',
        id: provider_attest_id
      ), alert: 'Failed to delete facility detail.'
    end
  end

  private

  def set_facility
    @facility = ProviderPersonalInformationFacility.find(params[:id])
  end

  def facility_params
    params.require(:provider_personal_information_facility).permit(
      :provider_attest_id,
      :caqh_provider_attest_id,
      :facility_name,
      :contact,
      :address,
      :addition_address,
      :city,
      :county,
      :state,
      :zip_code,
      :country,
      :facility_office_pnone,
      :facility_office_fax,
      :facility_office_email,
      :appointment_date,
      :department,
      :section_name,
      :facility_chair,
      :facility_chair_title,
      :status,
      :is_current,
      :is_primary_admitting_facility,
      :expiration_date,
      :is_restriction_of_privileges,
      :is_admit_patients_facility,
      :faciltiy_percentage,
      :is_hospital_based_practitioner,
      :is_admitting_arrangements,
      :is_following_physician,
      :show_on_tickler,
      :comments,
      :form_type
    )
  end
end
