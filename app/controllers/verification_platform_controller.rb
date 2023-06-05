class VerificationPlatformController < ApplicationController
  def index
    if params[:page]
      render params[:page]
    end
  end
end
