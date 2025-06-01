module Api
  module V1
    module Entities
      class ProvidersTimeLineEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the timeline record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :title, documentation: { type: 'String', desc: 'Title of the timeline event.' }
        expose :due_date, documentation: { type: 'DateTime', desc: 'Due date for the timeline event.' }
        expose :notes, documentation: { type: 'String', desc: 'Notes for the timeline event.' }
        expose :status, documentation: { type: 'String', desc: 'Status of the timeline event (e.g., pending, completed).' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
