class DeaImportUpload < ApplicationRecord
  # has_one_attached :file
  mount_uploader :file, DeaFileUploader
end
