module Api
  module V1
    module Entities
      class ProviderSourceDataEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the data record.' }
        expose :provider_source_id, documentation: { type: 'Integer', desc: 'ID of the associated ProviderSource.' }
        expose :data_key, documentation: { type: 'String', desc: 'Key identifying the data point.' }
        expose :data_value, documentation: { type: 'String', desc: 'Value of the data point.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
