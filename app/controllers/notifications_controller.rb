class NotificationsController < ApplicationController

  def index
    @notifications = current_user.notifications.newest_first
    @notifications.paginate(per_page: 20, page: params[:page] || 1)
  end
end