module Api
  module V1
    module Entities
      class PracticeTypeEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the practice type.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the practice type.' }
        expose :description, documentation: { type: 'String', desc: 'Description of the practice type.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the practice type was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the practice type was last updated.' }
      end
    end
  end
end
