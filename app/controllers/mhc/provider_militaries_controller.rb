class Mhc::ProviderMilitariesController < ApplicationController
    before_action :set_provider_military, only: [:update, :destroy]
  
    def index
      @provider_militaries = ProviderMilitary.where(provider_attest_id: params[:provider_attest_id])
      @new_provider_military = ProviderMilitary.new(provider_attest_id: params[:provider_attest_id])
    end
  
    def new
      @provider_military = ProviderMilitary.new
      @provider_attest_id = params[:provider_attest_id]
    end
  
    def create
      @provider_military = ProviderMilitary.new(provider_military_params)
  
      if @provider_military.save
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_military][:provider_attest_id]),
                    notice: 'Military service details added successfully.'
      else
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_military][:provider_attest_id]),
                    alert: 'Failed to add military service details.'
      end
    end
  
    def update
      @provider_military.assign_attributes(provider_military_params)
  
      if @provider_military.save
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: @provider_military.provider_attest_id),
                    notice: 'Military service details updated successfully.'
      else
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: @provider_military.provider_attest_id),
                    alert: 'Failed to update military service details.'
      end
    end
  
    def destroy
      if @provider_military.destroy
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: @provider_military.provider_attest_id),
                    notice: 'Military service details deleted successfully.'
      else
        redirect_to mhc_verification_platform_path(page_tab: 'registration'),
                    alert: 'There was an error deleting the military service details.'
      end
    end
  
    private
  
    def provider_military_params
      params.require(:provider_military).permit(
        :provider_attest_id,
        :last_location,
        :discharge_rank,
        :branch,
        :start_date,
        :end_date,
        :honorable_discharge_flag,
        :discharge_explanation,
        :reserve_guard_flag,
        :court_martial_flag,
        :court_martial_explanation,
        :active_duty,
        :type_of_discharge,
        :reserve_separation_month,
        :reserve_separation_year,
        :currently_active_reserve,
        :caqh_id,
        :npi_number,
        :medicare_upin_number,
        :tricare_provider,
        :tricare_group_number,
        :certified_workers_comp_provider,
        :certificate_number,
        :certified_qualified_medical_examiner,
        :agreed_medical_examiner,
        :us_military_service,
        :branch_of_military,
        :comments
      )
    end
  
    def set_provider_military
      @provider_military = ProviderMilitary.find(params[:id])
    end  
end
