module Api
  module V1
    module Entities
      class EnrollmentCommentEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the comment.' }
        expose :enrollment_provider_id, documentation: { type: 'Integer', desc: 'ID of the associated EnrollmentProvider.' }
        expose :enroll_group_id, documentation: { type: 'Integer', desc: 'ID of the associated EnrollGroup.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :user_id, documentation: { type: 'Integer', desc: 'ID of the User who made the comment.' }
        expose :body, documentation: { type: 'String', desc: 'The content of the comment.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
