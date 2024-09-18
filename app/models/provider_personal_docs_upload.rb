class ProviderPersonalDocsUpload < ApplicationRecord
  belongs_to :provider_attest
  belongs_to :provider_personal_information
  mount_uploader :file_upload, DocumentUploader
end
