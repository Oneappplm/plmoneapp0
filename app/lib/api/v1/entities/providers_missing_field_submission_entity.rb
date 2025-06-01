module Api
  module V1
    module Entities
      class ProvidersMissingFieldSubmissionEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the submission record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :completed_by, documentation: { type: 'Integer', desc: 'ID of the User who completed/submitted.' }
        expose :status, documentation: { type: 'String', desc: 'Status of the submission (e.g., pending, completed).' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
