module Api
  module V1
    module Entities
      class PeerRecommendationEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the recommendation record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the recommended Provider.' }
        expose :allow_recommendation, documentation: { type: 'Boolean', desc: 'Flag indicating if recommendation is allowed.' }
        expose :recommendation, documentation: { type: 'String', desc: 'The recommendation text or status.' }
        expose :document, documentation: { type: 'String', desc: 'Path/reference to an associated document.' }
        expose :notes, documentation: { type: 'String', desc: 'Additional notes.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
