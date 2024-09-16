class ManagePractitionersController < ApplicationController
  def index
    @practitioner = Practitioner.paginate(page: params[:page])
    @provider_personal_informations = ProviderPersonalInformation.paginate(per_page: 10, page: params[:page] || 1)
  end
end