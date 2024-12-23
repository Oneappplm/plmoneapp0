class Mhc::ManageClientsController < ApplicationController

	def index
    @q = ProviderPersonalInformation.ransack(params[:q])
    @provider_personal_informations = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
    @document = ProviderPersonalUploadedDoc.new
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
end
