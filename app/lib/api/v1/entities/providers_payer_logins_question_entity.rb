module Api
  module V1
    module Entities
      class ProvidersPayerLoginsQuestionEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the question record.' }
        expose :providers_payer_login_id, documentation: { type: 'Integer', desc: 'ID of the associated ProvidersPayerLogin.' }
        expose :question, documentation: { type: 'String', desc: 'The security question text.' }
        expose :answer, documentation: { type: 'String', desc: 'The answer to the security question.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
