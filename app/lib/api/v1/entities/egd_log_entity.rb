module Api
  module V1
    module Entities
      class EgdLogEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the EGD log entry.' }
        expose :enroll_group_id, documentation: { type: 'Integer', desc: 'Associated EnrollGroup ID.' }
        expose :action, documentation: { type: 'String', desc: 'Action performed in the log.' }
        expose :notes, documentation: { type: 'String', desc: 'Additional notes for the log entry.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the log was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the log was last updated.' }
      end
    end
  end
end
