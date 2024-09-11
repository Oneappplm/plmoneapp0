class ProviderPersonalDocsUpload < ApplicationRecord
  belongs_to :provider_attest

  mount_uploader :file_upload, DocumentUploader
end
