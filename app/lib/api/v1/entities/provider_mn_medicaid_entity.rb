module Api
  module V1
    module Entities
      class ProviderMnMedicaidEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the MN Medicaid record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :mn_medicaid_number, documentation: { type: 'String', desc: 'MN Medicaid number.' }
        expose :mn_medicaid_username, documentation: { type: 'String', desc: 'MN Medicaid username.' }
        expose :question, documentation: { type: 'String', desc: 'MN Medicaid security question.' }
        expose :answer, documentation: { type: 'String', desc: 'MN Medicaid security answer.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
