module Api
  module V1
    module Entities
      class EnrollmentGroupsDetailsQuestionEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the question record.' }
        expose :enroll_groups_detail_id, documentation: { type: 'Integer', desc: 'ID of the associated EnrollGroupsDetail.' }
        expose :secret_question, documentation: { type: 'String', desc: 'The secret question text.' }
        expose :answer, documentation: { type: 'String', desc: 'The answer to the secret question.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
