class Mhc::ManageClientsController < ApplicationController

  def index
    @q = ProviderPersonalInformation.ransack(params[:q])
    @provider_personal_informations = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
    @document = ProviderPersonalUploadedDoc.new
    @client_organizations = ClientOrganization.all
  end

  def new 
    @practitioner = ProviderPersonalInformation.new
  end

  def create
    ActiveRecord::Base.transaction do
      provider_attest = ProviderAttest.create!(
        caqh_provider_attest_id: random_id
      )

      @practitioner = ProviderPersonalInformation.new(
        practitioner_params.merge(
          caqh_provider_id: random_id,
          provider_attest_id: provider_attest.id,
          caqh_provider_attest_id: provider_attest.caqh_provider_attest_id
        )
      )

      @practitioner.save!
    end

    redirect_to mhc_manage_clients_path, notice: "Provider Personal Information saved successfully"

  rescue ActiveRecord::RecordInvalid => e
    @practitioner ||= ProviderPersonalInformation.new(practitioner_params)
    flash.now[:alert] = e.record.errors.full_messages.join(", ")
    render :new, status: :unprocessable_entity
  end

  def edit_provider_personal_information
    @providers = ProviderPersonalInformation.select(:id, :first_name, :middle_name, :last_name, :suffix, :practitioner_type).distinct
    @provider_personal_information = nil
  end

  def load_provider_personal_information
    provider_id = params[:provider_personal_information_id]
    @providers = ProviderPersonalInformation.select(:id, :first_name, :middle_name, :last_name, :suffix, :practitioner_type).distinct
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

    if @provider_personal_information.update(practitioner_params)
      redirect_to mhc_manage_clients_path, notice: 'Provider information updated successfully.'
    else
      @providers = ProviderPersonalInformation.select(:id, :first_name, :middle_name, :last_name, :suffix, :practitioner_type).distinct
      render :edit_provider_personal_information, status: :unprocessable_entity
    end
  end

  def ajax_upload
    provider_info = ProviderPersonalInformation.find(
      params[:provider_personal_uploaded_doc][:provider_personal_information_id]
    )

    doc_params = params.require(:provider_personal_uploaded_doc).permit(
      :file_upload,
      :image_classification,
      :sub_section,
      :description,
      :exclude_from_profile
    )

    if params[:document_id].present?
      # ✅ update existing record
      @document = ProviderPersonalUploadedDoc.find(params[:document_id])

      if @document.update(doc_params.merge(
        caqh_provider_attest_id: provider_info.caqh_provider_attest_id
      ))
        render json: {
          success: true,
          document_id: @document.id,
          file_name:  @document.file_upload.identifier,
          file_url:   @document.file_upload.url,
          uploaded_at: @document.updated_at.strftime("%d-%m-%Y %H:%M")
        }
      else
        render json: { success: false, errors: @document.errors.full_messages },
               status: :unprocessable_entity
      end
    else
      # ✅ create new record
      @document = ProviderPersonalUploadedDoc.new(
        doc_params.merge(
          provider_personal_information_id: provider_info.id,
          caqh_provider_attest_id: provider_info.caqh_provider_attest_id,
          provider_attest_id: provider_info.provider_attest_id
        )
      )

      Rails.logger.info doc_params.inspect
      Rails.logger.info @document.attributes.inspect

      if @document.save
        Rails.logger.info "Document saved successfully: #{@document.id}"

        begin
          render json: {
            success: true,
            document_id: @document.id,
            file_name: @document.file_upload.identifier,
            file_url: @document.file_upload.url,
            uploaded_at: @document.created_at.strftime("%d-%m-%Y %H:%M")
          }
        rescue => e
          Rails.logger.error "JSON RESPONSE ERROR: #{e.class} - #{e.message}"
          Rails.logger.error e.backtrace.first(20).join("\n")

          render json: {
            success: false,
            error: e.message
          }, status: :unprocessable_entity
        end
      else
        Rails.logger.error @document.errors.full_messages
        render json: {
          success: false,
          errors: @document.errors.full_messages
        }, status: :unprocessable_entity
      end
    end
  end

  def get_provider_uploaded_docs
    personal_information_id = params[:id]

    sql_order = <<-SQL
      CASE
        WHEN image_classification = 'application' THEN 1
        WHEN image_classification = 'profile' THEN 2
        WHEN image_classification = 'received_request' THEN 3
        ELSE 999
      END, created_at DESC
    SQL

    documents = ProviderPersonalUploadedDoc
                  .where(provider_personal_information_id: personal_information_id)
                  .order(Arel.sql(sql_order))

    render json: documents.map { |doc|
      {
        id: doc.id,
        image_classification: doc.image_classification,
        sub_section: doc.sub_section,
        # ✅ safer filename extraction for CarrierWave
        file_name: File.basename(doc.file_upload.path.to_s),
        # ✅ correct file URL for direct link
        file_url: doc.file_upload.url,
        created_at: doc.created_at,
        personal_information_id: doc.provider_personal_information_id
      }
    }
  end

  def show_uploaded_doc
    doc = ProviderPersonalUploadedDoc.find(params[:id])
    render json: {
      id: doc.id,
      image_classification: doc.image_classification,
      sub_section: doc.sub_section,
      description: doc.description,
      exclude_from_profile: doc.exclude_from_profile,
      file_url: doc.file_upload.url,          # ✅ use CarrierWave url
      file_name: doc.file_upload_identifier   # ✅ or doc.file_upload.filename if present
    }
  end

  def update_uploaded_doc
    doc = ProviderPersonalUploadedDoc.find(params[:id])

    if doc.update(provider_personal_uploaded_docs_params)
      render json: { success: true, message: "Document updated successfully.", doc: doc }
    else
      render json: { success: false, errors: doc.errors.full_messages },
             status: :unprocessable_entity
    end
  end


  def delete_provider_personal_docs
    doc = ProviderPersonalUploadedDoc.find(params[:doc_id])
    if doc.destroy
      render json: { success: true }
    else
      render json: { success: false }, status: :unprocessable_entity
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
      :provider_personal_information_id)
  end

  def random_id
    rand(10**8).to_s.rjust(8, '5')
  end

  def practitioner_params
    params.require(:provider_personal_information).permit(
      :id, :caqh_provider_id, :provider_attest_id, :caqh_provider_attest_id, :last_name, :first_name,
      :middle_name, :suffix, :primary_practice_state, :other_name_flag, :birth_date, :us_eligible_flag,
      :ssn, :nid, :dea_flag, :cds_flag, :upin, :upin_flag, :npi_flag, :npi, :medicare_provider_flag,
      :gender, :practitioner_type, :credentials_committee_date, :client_batch_date, :client_batch_name, :client_batch_id, :market, :status, :application_method, :availability,
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
