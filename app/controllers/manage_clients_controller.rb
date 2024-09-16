class ManageClientsController < ApplicationController

	def index
    @practitioner = Practitioner.paginate(page: params[:page])
    @provider_personal_informations = ProviderPersonalInformation.paginate(per_page: 10, page: params[:page] || 1)
    @document = ProviderPersonalUploadedDoc.new
  end

  def new 
    @practitioner = Practitioner.new
  end

  def create
    @practitioner = Practitioner.new(practitioner_params)

    if @practitioner.save
      redirect_to action: "index"
      else
      render :new, status: :unprocessable_entity
    end
  end

  def provider_personal_uploaded_docs
    provider_id = params[:provider_personal_uploaded_doc][:provider_id]

    @documents = ProviderPersonalUploadedDoc.where(provider_id: params[:provider_id])
    @document = ProviderPersonalUploadedDoc.new

    if request.post?
      @document = ProviderPersonalUploadedDoc.new(provider_personal_uploaded_docs_params)
      if @document.save
        redirect_to manage_clients_path, notice: 'Document uploaded successfully.'
      end
    end
  end

  def delete_provider_personal_docs
    doc_id = params.dig(:doc_id)
    doc_file = ProviderPersonalUploadedDoc.find_by_id(doc_id)
     if doc_file&.destroy
      redirect_to manage_clients_path, notice: 'Document deleted successfully.'
    end
  end

  private

  def provider_personal_uploaded_docs_params
    params.require(:provider_personal_uploaded_doc).permit(
      :image_classification, 
      :sub_section, 
      :record_item, 
      :description, 
      :exclude_from_profile, 
      :file_upload, 
      :provider_attest_id, 
      :provider_id)
  end


  def practitioner_params
    params.require(:practitioner).permit(:first_name, :middle_name, :last_name, :suffix, :gender, :date_of_birth, :social_security_number,
           :contact_method, :phone_number, :fax_number, :email_address, :address, :suit_or_apt,
           :additional_address, :city, :country, :state_or_province, :zipcode, :practitioner_type,
           :credentials_committee_date, :credentials_batch_date, :client_batch_name, :client_batch_id,
           :market, :status, :application_method, :availability, :county, :first_name_of_credentialing_contact,
           :middle_name_of_credentialing_contact, :last_name_of_credentialing_contact, :suffix_of_credentialing_contact)
  end
end
