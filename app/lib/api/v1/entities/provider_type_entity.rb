module Api
  module V1
    module Entities
      class ProviderTypeEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the provider type.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the provider type.' }
        expose :description, documentation: { type: 'String', desc: 'Description of the provider type.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the provider type was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the provider type was last updated.' }
      end
    end
  end
end
