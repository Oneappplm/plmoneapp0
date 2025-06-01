module Api
  module V1
    module Entities
      class SpecialtyEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the specialty.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the specialty.' }
        expose :description, documentation: { type: 'String', desc: 'Description of the specialty.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the specialty was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the specialty was last updated.' }
      end
    end
  end
end
