module Api
  module V1
    module Entities
      class VisaTypeEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the visa type.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the visa type.' }
        expose :description, documentation: { type: 'String', desc: 'Description of the visa type.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the visa type was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the visa type was last updated.' }
      end
    end
  end
end
