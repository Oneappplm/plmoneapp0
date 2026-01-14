class WorkTicklersController < ApplicationController

  def index
    # if params[:page]
    #   render params[:page]
    # end
    @q = ProviderPersonalInformation.where.not(cred_status: 'no-application').or(
       ProviderPersonalInformation.where(cred_status: nil)
     ).ransack(params[:q])
  end
end
