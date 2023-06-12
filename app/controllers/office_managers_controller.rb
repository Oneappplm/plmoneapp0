class OfficeManagersController < ApplicationController
  def index
    if params[:page].present?
      render params[:page]
    end
  end

  def send_invitation
    User.invite!(email: params[:emailTo], user_role: 'office_manager')
    render json: {
      status: 'success',
    } and return
  end
end
