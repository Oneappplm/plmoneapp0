class Mhc::ClientPortalController < ApplicationController
  before_action :set_provider_personal_informations, only: [:show, :edit, :update]
  before_action :redirect_to_auto_verify, only: [:index]
  before_action :get_provider_types, only: [:index]
  before_action :get_states, only: [:index]

  def index
    @q = ProviderPersonalInformation.ransack(params[:q]&.except(:advanced_search))
    @provider_personal_informations = @q.result(distinct: true).paginate(per_page: 100, page: params[:page] || 1)
  end

  def show
    if params[:page]
      render params[:page]
    else
      render 'overview'
    end
  end

  protected
  def get_provider_types
  	@provider_types = ProviderType.all
  end
  def get_states
  	@states = State.all
  end
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
