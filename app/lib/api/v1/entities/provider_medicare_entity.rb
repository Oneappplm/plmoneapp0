module Api
  module V1
    module Entities
      class ProviderMedicareEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the Medicare record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :ptan_number, documentation: { type: 'String', desc: 'Medicare PTAN number.' }
        expose :effective_date, documentation: { type: 'DateTime', desc: 'Medicare effective date.' }
        expose :medicare_username, documentation: { type: 'String', desc: 'Medicare username.' }
        expose :question, documentation: { type: 'String', desc: 'Medicare security question.' }
        expose :answer, documentation: { type: 'String', desc: 'Medicare security answer.' }
        expose :reval_date, documentation: { type: 'DateTime', desc: 'Medicare revalidation date.' }
        expose :notes, documentation: { type: 'String', desc: 'Notes related to Medicare enrollment.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
