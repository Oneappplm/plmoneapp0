class EnrollmentChangesNotification < Noticed::Base
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
    if params[:note] == "true"
      "A new note was added for #{params[:provider_full_name]} for #{params[:payer]}."
    elsif params[:changed_attributes_array].present?
      attributes = params[:changed_attributes_array]
      "A profile update was made for #{params[:provider_full_name]} : #{attributes.join(', ')} update."
    else
      "#{params[:provider_full_name]}'s initial application status for #{params[:payer]} change to #{params[:application_status]}"
    end
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