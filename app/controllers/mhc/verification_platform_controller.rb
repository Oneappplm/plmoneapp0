class Mhc::VerificationPlatformController < ApplicationController
  before_action :set_provider_personal_informations, only: [:show, :edit, :update]
  before_action :redirect_to_auto_verify, only: [:index]

  def index
    @provider_personal_informations = ProviderPersonalInformation.paginate(per_page: 10, page: params[:page] || 1)
  end

  def show
    if params[:page_tab]
      if params[:page_tab] == 'add_practice_info'
        @practice_information = PracticeInformation.new(provider_attest_id: @provider_personal_information.provider_attest_id, caqh_provider_attest_id: @provider_personal_information.caqh_provider_attest_id )
      end

      render params[:page_tab]
    else
      render 'overview'
    end
  end

  protected
  def set_provider_personal_informations
    @provider_personal_information = ProviderPersonalInformation.find(params[:id])
    @practice_informations = @provider_personal_information.provider_attest.practice_informations
  end

		def redirect_to_auto_verify
			if current_setting.dcs?
				redirect_to auto_verifies_path and return
			end
		end
end
