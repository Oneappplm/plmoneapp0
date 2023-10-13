class ManagePractitionersController < ApplicationController

  def index
     @practitioners = Practitioner.page(params[:page]).per(20)
  end
end