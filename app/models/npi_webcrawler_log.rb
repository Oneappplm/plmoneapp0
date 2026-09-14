class NpiWebcrawlerLog < ApplicationRecord
  belongs_to :provider_personal_information
  mount_uploader :filepath, DocumentUploader
end
