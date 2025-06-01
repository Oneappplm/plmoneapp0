module Api
  module V1
    module Entities
      class ProviderTaxonomyEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the taxonomy record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :taxonomy_code, documentation: { type: 'String', desc: 'Taxonomy code.' }
        expose :specialty, documentation: { type: 'String', desc: 'Associated specialty.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
