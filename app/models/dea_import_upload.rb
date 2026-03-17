class DeaImportUpload < ApplicationRecord
  mount_uploader :file, DocumentUploader

  # For direct-to-S3 uploads we do NOT attach file, we store s3_key
  # so allow file to be blank when s3_key is present.
  validates :file, presence: true, unless: -> { s3_key.present? }
  validates :s3_key, presence: true, unless: -> { file.present? }
end
