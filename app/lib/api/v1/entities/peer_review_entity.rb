module Api
  module V1
    module Entities
      class PeerReviewEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the peer review record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the reviewed Provider.' }
        expose :committee_date, documentation: { type: 'DateTime', desc: 'Date of the committee meeting.' }
        expose :review_status, documentation: { type: 'Integer', desc: 'Status of the review (e.g., 0 for pending, 1 for approved).' } # Consider mapping to string
        expose :feedback, documentation: { type: 'String', desc: 'Feedback provided during the review.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
