module Api
  module V1
    module Entities
      class AddScheduleEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the schedule.' }
        expose :group_name, documentation: { type: 'String', desc: 'Name of the group for the schedule.' }
        expose :description, documentation: { type: 'String', desc: 'Description of the schedule.' }
        expose :add_members, documentation: { type: 'Array[String]', desc: 'List of added members.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
