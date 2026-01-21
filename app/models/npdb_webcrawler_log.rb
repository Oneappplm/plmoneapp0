class NpdbWebcrawlerLog < ApplicationRecord
  belongs_to :provider_npdb
  belongs_to :rva_information

  # IMPORTANT: use your actual uploader class name
  # If your uploader is FileUploader, keep FileUploader
  mount_uploader :filepath, DocumentUploader
end
