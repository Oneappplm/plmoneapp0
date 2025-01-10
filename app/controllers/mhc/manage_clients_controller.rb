class Mhc::ManageClientsController < ApplicationController

	def index
    @q = ProviderPersonalInformation.ransack(params[:q])
    @provider_personal_informations = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
    @document = ProviderPersonalUploadedDoc.new
    @client_organizations = ClientOrganization.all
  end

  def new 
    @practitioner = Practitioner.new
  end

  def create
    @practitioner = Practitioner.new(practitioner_params)

    if @practitioner.save
      redirect_to mhc_manage_clients_path, notice: "Practitioner saved successfully"
      else
      render :new, status: :unprocessable_entity
    end
  end

  def edit_provider_personal_information
    @providers = ProviderPersonalInformation.select(:id, :first_name).distinct
    @provider_personal_information = nil
  end

  def load_provider_personal_information
    provider_id = params[:provider_personal_information_id]
    @providers = ProviderPersonalInformation.select(:id, :first_name).distinct
    @provider_personal_information = ProviderPersonalInformation.find_by(id: provider_id)

    if @provider_personal_information
      render :edit_provider_personal_information
    else
      redirect_to edit_provider_personal_information_mhc_manage_clients_path,
                  alert: 'Provider not found. Please select a valid provider.'
    end
  end

  def update_provider_personal_information
    @provider_personal_information = ProviderPersonalInformation.find(params[:id])

    if @provider_personal_information.update(provider_personal_information_params)
      redirect_to mhc_manage_clients_path, notice: 'Provider information updated successfully.'
    else
      @providers = ProviderPersonalInformation.select(:id, :first_name).distinct
      render :edit_provider_personal_information, status: :unprocessable_entity
    end
  end

  def provider_personal_uploaded_docs
    provider_id = params[:provider_personal_uploaded_doc][:provider_id]

    @documents = ProviderPersonalUploadedDoc.where(provider_id: params[:provider_id])
    @document = ProviderPersonalUploadedDoc.new

    if request.post?
      @document = ProviderPersonalUploadedDoc.new(provider_personal_uploaded_docs_params)
      if @document.save
        redirect_to mhc_manage_clients_path, notice: 'Document uploaded successfully.'
      end
    end
  end

  def delete_provider_personal_docs
    doc_id = params.dig(:doc_id)
    doc_file = ProviderPersonalUploadedDoc.find_by_id(doc_id)
     if doc_file&.destroy
      redirect_to mhc_manage_clients_path, notice: 'Document deleted successfully.'
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
      :provider_personal_information_id)
  end

  def practitioner_params
    params.require(:provider_personal_information).permit(
      :id, :caqh_provider_id, :provider_attest_id, :caqh_provider_attest_id, :last_name, :first_name,
      :middle_name, :suffix, :primary_practice_state, :other_name_flag, :birth_date, :us_eligible_flag,
      :ssn, :nid, :dea_flag, :cds_flag, :upin, :upin_flag, :npi_flag, :npi, :medicare_provider_flag,
      :medicaid_provider_flag, :other_graduate_education_flag, :fellowship_training_flag, :teaching_appointment_flag,
      :secondary_specialty_flag, :other_specialty_flag, :hospital_privilege_flag, :hospital_admitting_arrangements,
      :work_history_gap_flag, :active_military_flag, :citizenship_status, :visa_number, :federal_employee_id,
      :no_malpractice_claims_flag, :application_type, :ecfmg_flag, :ecfmg_number, :ecfmg_issue_date,
      :hospital_based_flag, :email_address, :visa_type, :visa_status, :birth_city, :birth_state,
      :tax_id, :spouse_last_name, :spouse_first_name, :other_correspondence_address,
      :emergency_contact_last_name, :emergency_contact_first_name, :emergency_contact_middle_name,
      :emergency_contact_phone, :pager_beeper_number, :answering_service_phone_number, :cell_phone_number,
      :pager_beeper_digital_flag, :visa_expiration_date, :ethnicity_description, :visa_issue_date,
      :ecfmg_expiration_date, :work_permit_status, :spouse_middle_name,
      :state_residence_date, :citizenship_country_country_name, :marital_status_marital_status_description,
      :gender_gender_description, :birth_country_country_name, :correspondence_address_type_correspondence_address_type_descrip,
      :provider_type_provider_type_abbreviation, :graduate_type_graduate_type_description,
      :nid_country_country_name, :attest_date, :plan_provider_id, :last_recredential_date, :next_recredential_date,
      :npi_verification_status,
      provider_personal_information_credentialing_contact_attributes: [:id, :contact_method,
      :firstname, :middlename, :lastname, :title, :address, :suffix, :phone_number, :fax, :email, :suite, :address2,
      :city, :county, :state, :zip, :country],
      provider_personal_information_confidential_contact_attributes: [:id, :contact_method,
      :firstname, :middlename, :lastname, :title, :address, :suffix, :phone_number, :fax, :email, :suite, :address2,
      :city, :county, :state, :zip, :country])
  end
end
