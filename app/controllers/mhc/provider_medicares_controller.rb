class Mhc::ProviderMedicaresController < ApplicationController
    before_action :set_provider_medicare, only: [:update, :destroy]
  
    def index
      @provider_medicares = ProviderMedicare.where(provider_attest_id: params[:provider_attest_id])
      @new_provider_medicare = ProviderMedicare.new(provider_attest_id: params[:provider_attest_id])
    end
  
    def new
      @provider_medicare = ProviderMedicare.new
      @provider_personal_information = ProviderPersonalInformation.find(params[:provider_personal_information_id])
      @provider_attest_id = @provider_personal_information.provider_attest_id
    end
  
    def create
      @provider_medicare = ProviderMedicare.new(provider_medicare_params)
  
      if @provider_medicare.save
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_medicare][:provider_attest_id]),
                    notice: 'Medicare Billing Number added successfully.'
      else
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_medicare][:provider_attest_id]),
                    alert: 'Failed to add Medicare Billing Number.'
      end
    end
  
    def update
      @provider_medicare.assign_attributes(provider_medicare_params)
  
      if @provider_medicare.save
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_medicare][:provider_attest_id]),
                    notice: 'Medicare Billing Number updated successfully.'
      else
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_medicare][:provider_attest_id]),
                    alert: 'Failed to update Medicare Billing Number.'
      end
    end
  
    def destroy
      if @provider_medicare.destroy
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: @provider_medicare.provider_attest_id || params[:provider_attest_id]),
                    notice: 'Medicare Billing Number deleted successfully.'
      else
        redirect_to mhc_verification_platform_path(page_tab: 'registration'),
                    alert: 'There was an error deleting the Medicare Billing Number.'
      end
    end
  
    private
  
    def provider_medicare_params
      params.require(:provider_medicare).permit(
        :provider_attest_id,
        :medicare_number,
        :issue_date,
        :state,
        :medicare_opt_in,
        :medicare_opt_out,
        :medicare_partial,
      )
    end
  
    def set_provider_medicare
      @provider_medicare = ProviderMedicare.find(params[:id])
    end  
end
