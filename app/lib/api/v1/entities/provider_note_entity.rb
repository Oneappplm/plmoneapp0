module Api
  module V1
    module Entities
      class ProviderNoteEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the note.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :title, documentation: { type: 'String', desc: 'Title of the note.' }
        expose :description, documentation: { type: 'String', desc: 'Content/description of the note.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
