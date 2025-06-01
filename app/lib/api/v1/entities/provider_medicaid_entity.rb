module Api
  module V1
    module Entities
      class ProviderMedicaidEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the Medicaid record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :effective_date, documentation: { type: 'DateTime', desc: 'Medicaid effective date.' }
        expose :reval_date, documentation: { type: 'DateTime', desc: 'Medicaid revalidation date.' }
        expose :notes, documentation: { type: 'String', desc: 'Notes related to Medicaid enrollment.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
