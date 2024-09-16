class Mhc::ManagePractitionersController < ApplicationController
  def index
    @provider_personal_informations = ProviderPersonalInformation.paginate(per_page: 10, page: params[:page] || 1)
  end
end
