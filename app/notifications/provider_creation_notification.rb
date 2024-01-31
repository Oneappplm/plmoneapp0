class ProviderCreationNotification < Noticed::Base
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
    "Profile created for #{params[:provider_full_name].present? ? params[:provider_full_name]: "provider" }. Please complete all information."
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