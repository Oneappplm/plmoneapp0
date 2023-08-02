# To deliver this notification:
#
# ProvidersMissingFieldSubmissionNotification.with(post: @post).deliver_later(current_user)
# ProvidersMissingFieldSubmissionNotification.with(submitted_fields: @submitted_fields).deliver(User.agents)

class ProvidersMissingFieldSubmissionNotification < Noticed::Base
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
    "#{params[:provider_full_name].blank? ? 'A provider' : params[:provider_full_name]} filled out some missing fields."
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
