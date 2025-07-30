class VerificationPlatformController < ApplicationController
  before_action :set_provider_personal_information, only: [:show, :edit, :update, :destroy]

  def index
    @q = ProviderPersonalInformation.ransack(params[:q])
    
    if params[:page]
      render params[:page]
    else
      @provider_personal_information = if params[:search].present?
        ProviderPersonalInformation.search(params[:search]).paginate(per_page: 10, page: params[:page] || 1)
      else
        @q.result.paginate(per_page: 10, page: params[:page] || 1)
      end
    end
  end

  def show
    render 'overview'
  end

  protected
  def set_provider_personal_information
    @provider_personal_information = ProviderPersonalInformation.find(params[:id])
  end

		def redirect_to_auto_verify
			if current_setting.dcs?
				redirect_to auto_verifies_path and return
			end
		end
end
