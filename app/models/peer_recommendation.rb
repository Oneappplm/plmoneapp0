class PeerRecommendation < ApplicationRecord
  mount_uploader :document, DocumentUploader
  belongs_to :provider
end
