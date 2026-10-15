class OigWebcrawlerLog < ApplicationRecord
  belongs_to :rva_information
  mount_uploader :filepath, DocumentUploader
end
