module Api
  module V1
    module Entities
      class ServiceEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the service.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the service.' }
        expose :description, documentation: { type: 'String', desc: 'Description of the service.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the service was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the service was last updated.' }
      end
    end
  end
end
