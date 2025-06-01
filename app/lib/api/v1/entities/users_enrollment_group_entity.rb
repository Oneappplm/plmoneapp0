module Api
  module V1
    module Entities
      class UsersEnrollmentGroupEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the association record.' }
        expose :user_id, documentation: { type: 'Integer', desc: 'ID of the associated User.' }
        expose :enrollment_group_id, documentation: { type: 'Integer', desc: 'ID of the associated Enrollment Group.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the association was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the association was last updated.' }
      end
    end
  end
end
