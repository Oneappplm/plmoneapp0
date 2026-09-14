class Mhc::ProviderMedicaidsController < ApplicationController
    before_action :set_provider_medicaid, only: [:update, :destroy]
  
    def index
      @provider_medicaids = ProviderMedicaid.where(provider_attest_id: params[:provider_attest_id])
      @new_provider_medicaid = ProviderMedicaid.new(provider_attest_id: params[:provider_attest_id])
    end
  
    def new
      @provider_medicaid = ProviderMedicaid.new
      @provider_personal_information = ProviderPersonalInformation.find(params[:provider_personal_information_id])
      @provider_attest_id = @provider_personal_information.provider_attest_id
    end
  
    def create
      @provider_medicaid = ProviderMedicaid.new(provider_medicaid_params)
  
      if @provider_medicaid.save
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_medicaid][:provider_attest_id]),
                    notice: 'Medicaid Billing Number added successfully.'
      else
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_medicaid][:provider_attest_id]),
                    alert: 'Failed to add Medicaid Billing Number.'
      end
    end
  
    def update
      @provider_medicaid.assign_attributes(provider_medicaid_params)
  
      if @provider_medicaid.save
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_medicaid][:provider_attest_id]),
                    notice: 'Medicaid Billing Number updated successfully.'
      else
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_medicaid][:provider_attest_id]),
                    alert: 'Failed to update Medicaid Billing Number.'
      end
    end
  
    def destroy
      if @provider_medicaid.destroy
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: @provider_medicaid.provider_attest_id || params[:provider_attest_id]),
                    notice: 'Medicaid Billing Number deleted successfully.'
      else
        redirect_to mhc_verification_platform_path(page_tab: 'registration'),
                    alert: 'There was an error deleting the Medicaid Billing Number.'
      end
    end
  
    private
  
    def provider_medicaid_params
      params.require(:provider_medicaid).permit(
        :provider_attest_id,
        :medicaid_number,
        :state,
      )
    end
  
    def set_provider_medicaid
      @provider_medicaid = ProviderMedicaid.find(params[:id])
    end  
end
