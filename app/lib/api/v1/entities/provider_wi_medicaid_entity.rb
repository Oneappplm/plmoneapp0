module Api
  module V1
    module Entities
      class ProviderWiMedicaidEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the WI Medicaid record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :wi_medicaid, documentation: { type: 'String', desc: 'WI Medicaid number/identifier.' }
        expose :wi_medicaid_username, documentation: { type: 'String', desc: 'WI Medicaid username.' }
        expose :question, documentation: { type: 'String', desc: 'WI Medicaid security question.' }
        expose :answer, documentation: { type: 'String', desc: 'WI Medicaid security answer.' }
        expose :notes, documentation: { type: 'String', desc: 'Notes related to WI Medicaid enrollment.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
