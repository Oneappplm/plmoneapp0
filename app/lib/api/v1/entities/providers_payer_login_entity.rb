module Api
  module V1
    module Entities
      class ProvidersPayerLoginEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the payer login record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :enrollment_payer, documentation: { type: 'String', desc: 'Name of the enrollment payer.' }
        expose :state_id, documentation: { type: 'Integer', desc: 'ID of the associated State.' }
        expose :username, documentation: { type: 'String', desc: 'Username for the payer login.' }
        expose :notes, documentation: { type: 'String', desc: 'Notes related to the payer login.' }
        expose :cred_current_reattest_date, documentation: { type: 'Date', desc: 'Credentialing current reattestation date.' }
        expose :cred_reattest_date, documentation: { type: 'Date', desc: 'Credentialing reattestation date.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
