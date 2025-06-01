module Api
  module V1
    module Entities
      class GroupDcoScheduleEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the schedule record.' }
        expose :group_dco_id, documentation: { type: 'Integer', desc: 'ID of the associated GroupDco.' }
        expose :day, documentation: { type: 'String', desc: 'Day of the week for the schedule.' }
        expose :start_time, documentation: { type: 'String', desc: 'Start time for the schedule.' }
        expose :end_time, documentation: { type: 'String', desc: 'End time for the schedule.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
