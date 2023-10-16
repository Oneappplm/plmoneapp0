class ManagePractitionersController < ApplicationController
  def index
    @practitioner = Practitioner.paginate(page: params[:page])
  end
end