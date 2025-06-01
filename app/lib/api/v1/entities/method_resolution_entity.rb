module Api
  module V1
    module Entities
      class MethodResolutionEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the method resolution.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the method resolution.' }
        expose :description, documentation: { type: 'String', desc: 'Description of the method resolution.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the method resolution was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the method resolution was last updated.' }
      end
    end
  end
end
