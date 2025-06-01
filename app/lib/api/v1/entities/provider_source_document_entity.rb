module Api
  module V1
    module Entities
      class ProviderSourceDocumentEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the provider source document.' }
        expose :provider_source_id, documentation: { type: 'Integer', desc: 'ID of the associated ProviderSource.' }
        expose :document_type, documentation: { type: 'String', desc: 'Type of the document.' }
        expose :file_url, documentation: { type: 'String', desc: 'URL of the uploaded file.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the document was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the document was last updated.' }
      end
    end
  end
end
