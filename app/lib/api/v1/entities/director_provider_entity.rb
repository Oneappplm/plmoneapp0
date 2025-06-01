module Api
  module V1
    module Entities
      class DirectorProviderEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the association.' }
        expose :user_id, documentation: { type: 'Integer', desc: 'ID of the associated User (Director).' }
        expose :virtual_review_committee_id, documentation: { type: 'Integer', desc: 'ID of the associated Virtual Review Committee.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the association was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the association was last updated.' }
      end
    end
  end
end
