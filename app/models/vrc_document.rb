class VrcDocument < ApplicationRecord
  mount_uploader :file_upload, DocumentUploader
end
