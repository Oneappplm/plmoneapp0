module Api
  module V1
    module Entities
      class StateEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the state.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the state.' }
        expose :abbreviation, documentation: { type: 'String', desc: 'Two-letter state abbreviation.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the state was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the state was last updated.' }
      end
    end
  end
end
