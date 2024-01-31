class GroupCreationNotification < Noticed::Base
   # Add your delivery methods
  #
  deliver_by :database, format: :to_database
  # deliver_by :email, mailer: "UserMailer"
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  def to_database
    {
      type: self.class.name,
      params: params
    }
  end

  # Add required params
  #
  # param :post

  # Define helper methods to make rendering easier.
  #
  def message
    "Profile created for #{params[:group_name].present? ?  params[:group_name] : "group"}. Please complete all information."
  end
  #
  def url
    if params[:group_id].blank?
      "javascript:void(0);"
    else
      alt_enrollment_group_path(params[:group_id])
    end
  end
end 