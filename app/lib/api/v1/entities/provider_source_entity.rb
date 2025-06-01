module Api
  module V1
    module Entities
      class ProviderSourceEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the provider source record.' }
        expose :status, documentation: { type: 'String', desc: 'Status of the provider source (e.g., draft, submitted).' }
        expose :current_provider_source, documentation: { type: 'Boolean', desc: 'Flag indicating if this is the current source.' }
        expose :invitation_count, documentation: { type: 'Integer', desc: 'Number of invitations sent.' }
        expose :invitation_sent_at, documentation: { type: 'DateTime', desc: 'Timestamp when the last invitation was sent.' }
        expose :practice_location_id, documentation: { type: 'Integer', desc: 'ID of the associated PracticeLocation.' }
        expose :group_engage_provider_id, documentation: { type: 'Integer', desc: 'ID of the associated GroupEngageProvider.' }
        expose :created_by_user, documentation: { type: 'Integer', desc: 'ID of the User who created this source record.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
