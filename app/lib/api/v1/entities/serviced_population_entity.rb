module Api
  module V1
    module Entities
      class ServicedPopulationEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the serviced population.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the serviced population.' }
        expose :description, documentation: { type: 'String', desc: 'Description of the serviced population.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the serviced population was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the serviced population was last updated.' }
      end
    end
  end
end
