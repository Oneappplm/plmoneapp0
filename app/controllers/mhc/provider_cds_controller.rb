class Mhc::ProviderCdsController < ApplicationController
    before_action :set_provider_cd, only: [:update, :destroy]
    
    def index
      @provider_cds = ProviderCd.where(caqh_provider_attest_id: params[:caqh_provider_attest_id])
      @new_provider_cd = ProviderCd.new(caqh_provider_attest_id: params[:caqh_provider_attest_id], provider_attest_id: params[:provider_attest_id])
    end

    def new
      @provider_cd = ProviderCd.new
      @provider_personal_information = ProviderPersonalInformation.find(params[:provider_personal_information_id])
      @caqh_provider_attest_id = @provider_personal_information.caqh_provider_attest_id
    end
    
    
    def create
      @provider_cd = ProviderCd.new(provider_cd_params)
  
      if @provider_cd.save
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_cd][:provider_attest_id]),
                    notice: 'CDS/DPS Number added successfully.'
      else
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_cd][:provider_attest_id]),
                    alert: 'Failed to add CDS/DPS Number.'
      end
    end
  
    def update
      @provider_cd.assign_attributes(provider_cd_params)
  
      if @provider_cd.save
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_cd][:provider_attest_id]),
                    notice: 'CDS/DPS Number updated successfully.'
      else
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_cd][:provider_attest_id]),
                    alert: 'Failed to update CDS/DPS Number.'
      end
    end
  
    def destroy
      if @provider_cd.destroy
        # Ensure provider_attest_id is present
        redirect_to mhc_verification_platform_path(page_tab: 'registration', id: @provider_cd.provider_attest_id || params[:provider_attest_id]),
                    notice: 'CDS/DPS Number deleted successfully.'
      else
        redirect_to mhc_verification_platform_path(page_tab: 'registration'), 
                    alert: 'There was an error deleting the CDS/DPS Number.'
      end
    end    

    # app/controllers/mhc/provider_cds_controller.rb (or wherever CDS lives)
    def quality_audit_details
      provider_cd = ProviderCd.find(params[:id])

      # last "active" rva info for CDS (ignore restarted)
      last_rva_information = provider_cd.rva_informations
                                        .where(tab: 'CDS')
                                        .where(restart_audit: [false, nil])
                                        .last

      render json: {
        success: true,
        rva_information: last_rva_information
      }, status: :ok
    end

  
    private
  
    def provider_cd_params
      params.require(:provider_cd).permit(
        :caqh_provider_cdsid,
        :provider_attest_id,
        :caqh_provider_attest_id,
        :cds_number,
        :state,
        :expiration_date,
        :issue_date,
        :currently_practicing_flag,
        :cds_limitation_explanation,
        :cds_status,
        :show_on_tickler
      )
    end
  
    def set_provider_cd
      @provider_cd = ProviderCd.find(params[:id])
    end  
end
