module Api
  module V1
    module Entities
      class EpdQuestionEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the EPD question record.' }
        expose :enrollment_providers_detail_id, documentation: { type: 'Integer', desc: 'ID of the associated EnrollmentProvidersDetail.' }
        expose :question, documentation: { type: 'String', desc: 'The question text.' }
        expose :answer, documentation: { type: 'String', desc: 'The answer text.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
