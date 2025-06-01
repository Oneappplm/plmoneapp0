module Api
  module V1
    module Entities
      class LanguageEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the language.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the language.' }
        expose :code, documentation: { type: 'String', desc: 'Language code.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the language was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the language was last updated.' }
      end
    end
  end
end
