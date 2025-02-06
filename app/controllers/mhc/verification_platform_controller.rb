class Mhc::VerificationPlatformController < ApplicationController
  before_action :set_provider_personal_informations, only: [:show, :edit, :update]
  before_action :redirect_to_auto_verify, only: [:index]

  def index
    @provider_personal_informations = ProviderPersonalInformation.paginate(per_page: 10, page: params[:page] || 1)
  end

  def show
    if params[:page]
      render params[:page]
    else
      render 'overview'
    end
  end

  protected
  def set_provider_personal_informations
    @provider_personal_information = ProviderPersonalInformation.find_by(provider_attest_id: params[:id])
    # @practice_informations = @provider_personal_information.provider_attest.practice_informations
  end

		def redirect_to_auto_verify
			if current_setting.dcs?
				redirect_to auto_verifies_path and return
			end
		end
end
