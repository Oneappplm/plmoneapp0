class ManageClientsController < ApplicationController
  before_action :set_practitioner, only: [:upload_document, :practitioner, :view_uploaded_documents]

  def index
    @practitioners = Practitioner.all
    @client_organizations = ClientOrganization.paginate(per_page: 10, page: params[:page] || 1)
    @document = PractitionerUploadedDocument.new
  end

  def upload_document
    @document = PractitionerUploadedDocument.new(practitioner_uploaded_document_params)
    if @document.save
      redirect_to manage_clients_path, notice: "Document uploaded successfully."
    else
      flash.now[:alert] = "Error uploading document."
      render :index
    end
  end

  def delete_uploaded_document
    doc_id = params.dig(:doc_id)
    doc_file = PractitionerUploadedDocument.find_by_id(doc_id)
    
    if doc_file&.destroy
      redirect_to request.referrer, notice: "Successfully deleted."
    else
      redirect_to request.referrer, alert: "Something went wrong."
    end
  end

  def view_uploaded_documents
    # This action can be used for rendering specific documents if needed
  end

  protected

  def practitioner_uploaded_document_params
    params.require(:practitioner_uploaded_document).permit(
      :practitioner_id,
      :image_classification,
      :sub_section,
      :description,
      :exclude_from_profile,
      :file_upload
    )
  end

  private

  def practitioner_uploaded_document_params
    params.require(:practitioner_uploaded_document).permit(:practitioner_id, :image_classification, :sub_section, :description, :exclude_from_profile, :file_upload)
  end

  def set_practitioner
    @practitioner = Practitioner.find_by_id params.dig(:id)
  end

end

