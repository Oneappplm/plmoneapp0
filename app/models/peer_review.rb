class PeerReview < ApplicationRecord
  belongs_to :provider

  enum review_status: [ :pending, :approved, :rejected ]
end
