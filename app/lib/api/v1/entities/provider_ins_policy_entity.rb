module Api
  module V1
    module Entities
      class ProviderInsPolicyEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the insurance policy record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :ins_policy_number, documentation: { type: 'String', desc: 'Insurance policy number.' }
        expose :effective_date, documentation: { type: 'DateTime', desc: 'Policy effective date.' }
        expose :expiration_date, documentation: { type: 'DateTime', desc: 'Policy expiration date.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
