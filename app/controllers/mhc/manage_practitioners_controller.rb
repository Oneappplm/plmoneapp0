class Mhc::ManagePractitionersController < ApplicationController
  def index
    @q = ProviderPersonalInformation.ransack(params[:q])
    @provider_personal_informations = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
  end
end
