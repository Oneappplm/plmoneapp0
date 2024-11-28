class Mhc::ProviderSpecialtiesController < ApplicationController
  def index
    @provider_specialty = ProviderSpecialty.all
  end  
  

  def new
    @provider_specialty = ProviderSpecialty.new
  end

  def create
    @provider_specialty = ProviderSpecialty.new(provider_specialty_params)

    if @provider_specialty.save
      redirect_to mhc_verification_platform_path(
        page_tab: 'board_cert',
        id: @provider_specialty.provider_attest_id || params[:provider_specialty][:provider_attest_id]
      ),
      notice: 'Board certification saved successfully.'
    else
      flash[:alert] = 'Failed to save board certification.'
      redirect_to mhc_verification_platform_path(
        page_tab: 'add_new_board_cert',
        id: params[:provider_specialty][:provider_attest_id]
      )
    end
  end
    
    def edit
      @provider_specialty = ProviderSpecialty.find(params[:id])
    end
    
    def update
      @provider_specialty = ProviderSpecialty.find(params[:id]) # Fetch the record to update

      if @provider_specialty.update(provider_specialty_params)
        redirect_to mhc_verification_platform_path(
          page_tab: 'board_cert',
          id: @provider_specialty.provider_attest_id
        ), notice: 'Board certification updated successfully.'
      else
        flash[:alert] = 'Failed to update board certification.'
        render :edit # Ensure you have an `edit` view template
      end
    end
 
    def destroy
      @provider_specialty = ProviderSpecialty.find(params[:id])
      
      if @provider_specialty.destroy
        redirect_to mhc_verification_platform_path(page_tab: 'board_cert', id: @provider_specialty.provider_attest_id), alert: 'Board certification detail deleted successfully.'
      else
        flash[:error] = 'Failed to delete the board certification.'
        redirect_to mhc_verification_platform_path(page_tab: 'board_cert')
      end
    end  

  private
  def provider_specialty_params
    params.require(:provider_specialty).permit(
      :provider_attest_id,
      :caqh_provider_attest_id,
      :specialty_specialty_name,
      :board_certified_flag,
      :specialty_board_name,
      :initial_certification_date,
      :expiration_date,
      :board_certification_expires_flag,
      :failed_board_exam_flag,
      :failed_board_exam_explanation,
      :hmo_flag,
      :ppo_flag,
      :pos_flag,
      :applied_board_certificate,
      :certification_name,
      :date_applied,
      :tickler,
      :comments
    )
  end  
end
