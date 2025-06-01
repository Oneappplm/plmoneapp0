module Api
  module V1
    module Entities
      class ProviderDeletedDocumentLogEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the deleted document log.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated provider.' }
        expose :document_type, documentation: { type: 'String', desc: 'Type of document deleted.' }
        expose :reason, documentation: { type: 'String', desc: 'Reason for deletion.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the log was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the log was last updated.' }
      end
    end
  end
end
