class ProviderEmailCreationNotification < Noticed::Base
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
    "Welcome letter is successfully sent to #{params[:provider_fullname].present? ? params[:provider_fullname]: "provider"}. "
  end
  #
  def url
    if params[:provider_id].blank?
      "javascript:void(0);"
    else
      provider_path(id: params[:provider_id])
    end
  end
end 