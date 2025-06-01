module Api
  module V1
    module Entities
      class ClientProviderEnrollmentEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the client provider enrollment.' }
        expose :client_id, documentation: { type: 'Integer', desc: 'Client ID.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'Provider ID.' }
        expose :status, documentation: { type: 'String', desc: 'Status of the enrollment.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the enrollment was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the enrollment was last updated.' }
      end
    end
  end
end
