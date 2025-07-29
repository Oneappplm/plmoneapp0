class Mhc::ProviderEmploymentsController < ApplicationController
    before_action :set_provider_employment, only: [:update, :destroy]
    
    def new
      @provider_employment = ProviderEmployment.new(provider_attest_id: params[:provider_attest_id])
    end
    
    def index
      @provider_employments = ProviderEmployment.all
    end
  
    def create
      @provider_employment = ProviderEmployment.new(provider_employment_params)
      @provider_employment.provider_attest_id = params[:provider_attest_id] if @provider_employment.provider_attest_id.nil?
  
      if @provider_employment.save
        redirect_to mhc_verification_platform_path(page_tab: 'employment', id: params[:provider_employment][:provider_attest_id]), notice: 'Employment detail saved successfully.'
      else
        redirect_to mhc_verification_platform_path(page_tab: 'employment_record', id: params[:provider_employment][:provider_attest_id]), alert: 'Failed to save employment detail.'
      end
    end
  
    def update
      @provider_employment.assign_attributes(provider_employment_params)
  
      if @provider_employment.save
        redirect_to mhc_verification_platform_path(page_tab: 'employment', id: params[:provider_employment][:provider_attest_id]), notice: 'Employment detail updated successfully.'
      else
        redirect_to mhc_verification_platform_path(page_tab: 'employment_record', id: params[:provider_employment][:provider_attest_id]), alert: 'Failed to update employment detail.'
      end
    end
  
    def destroy
      if @provider_employment.destroy
        redirect_to mhc_verification_platform_path(page_tab: 'employment', id: @provider_employment.provider_attest_id), notice: 'Employment detail deleted successfully.'
      else
        redirect_to mhc_verification_platform_path(page_tab: 'employment', id: @provider_employment.provider_attest_id), alert: 'Failed to delete employment detail.'
      end
    end
  
    private
  
    def set_provider_employment
      @provider_employment = ProviderEmployment.find(params[:id])
    end
  
    def provider_employment_params
      params.require(:provider_employment).permit(
        :provider_attest_id, :employer_name, :title, :contact_first_name, :contact_middle_name,
        :contact_last_name, :contact_suffix, :practitioner_type, :address, :mail_stop, :additional_address,
        :city, :county, :state, :country, :zip, :phone_number, :fax, :email, :work_status, :population_serviced,
        :contact_method, :from_date, :to_date, :position, :show_on_tickler, :comments
      )
    end  
end
