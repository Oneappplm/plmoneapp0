class ManageClientsController < ApplicationController

	def index
    @provider_personal_information = ProviderPersonalInformation.paginate(page: params[:page])
  end

  def new 
    @provider_personal_information = ProviderPersonalInformation.new
    @provider_personal_information.build_provider_personal_information_credentialing_contact
  end

  def create
    @provider_personal_information = ProviderPersonalInformation.new(practitioner_params)
  
    # Attempt to save the record without running validations
    if @provider_personal_information.save(validate: false)
      redirect_to mhc_manage_clients_path, notice: "Practitioner created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end
  

  private

  def practitioner_params
    params.require(:provider_personal_information).permit(:first_name, :middle_name, :last_name, :suffix, :gender, :date_of_birth,
      :ssn, :practitioner_type, :credentials_committee_date, :client_batch_date, :availability,
      :client_batch_name, :client_batch_id, :market, :status, :application_method,
      provider_personal_information_credentialing_contact_attributes: [:firstname, :middlename, :lastname, :suffix_of_credentialing_contact, :contact_method, :phone_number, :fax_number, :email_address, :address, :suit_or_apt, :additional_address, :city, :county, :state_or_province, :zipcode, :country,]
    )
  end
end
