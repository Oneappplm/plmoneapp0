module Api
  module V1
    module Entities
      class ProviderSourceCmeEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the CME record.' }
        expose :provider_source_id, documentation: { type: 'Integer', desc: 'ID of the associated ProviderSource.' }
        expose :training, documentation: { type: 'String', desc: 'Name or description of the training.' }
        expose :month_attended, documentation: { type: 'String', desc: 'Month the training was attended.' }
        expose :year_attended, documentation: { type: 'String', desc: 'Year the training was attended.' }
        expose :hours, documentation: { type: 'String', desc: 'Number of hours for the CME.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
