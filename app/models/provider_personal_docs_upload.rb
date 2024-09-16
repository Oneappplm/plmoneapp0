class ProviderPersonalDocsUpload < ApplicationRecord
  belongs_to :provider_attest
  belongs_to :provider_personal_information, foreign_key: [:provider_attest_id, :provider_id]
  mount_uploader :file_upload, DocumentUploader
end
