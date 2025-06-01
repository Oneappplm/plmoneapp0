module Api
  module V1
    module Entities
      class TrainingTypeEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the training type.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the training type.' }
        expose :description, documentation: { type: 'String', desc: 'Description of the training type.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the training type was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the training type was last updated.' }
      end
    end
  end
end
