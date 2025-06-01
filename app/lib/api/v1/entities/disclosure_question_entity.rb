module Api
  module V1
    module Entities
      class DisclosureQuestionEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the disclosure question.' }
        expose :disclosure_category_id, documentation: { type: 'Integer', desc: 'ID of the associated DisclosureCategory.' }
        expose :question, documentation: { type: 'String', desc: 'The text of the question.' }
        expose :slug, documentation: { type: 'String', desc: 'Unique slug for the question.' }
        expose :note, documentation: { type: 'String', desc: 'Note associated with the question.' }
        expose :alert_type, documentation: { type: 'String', desc: 'Type of alert associated with the question.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
