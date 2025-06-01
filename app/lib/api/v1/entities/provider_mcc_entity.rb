module Api
  module V1
    module Entities
      class ProviderMccEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the MCC record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :mcc_username, documentation: { type: 'String', desc: 'MCC username.' }
        expose :mcc_electronic_signature_code, documentation: { type: 'String', desc: 'MCC electronic signature code.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
