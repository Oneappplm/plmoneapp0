class UserLockedOutNotification < Noticed::Base
  deliver_by :database, format: :to_database

  def to_database
    {
      type: self.class.name,
      params: params
    }
  end

  param :user

  def message
    "User #{params[:user].email} has been locked out."
  end

  def url
    edit_user_path(params[:user]) unless params[:user].blank?
  end
end
