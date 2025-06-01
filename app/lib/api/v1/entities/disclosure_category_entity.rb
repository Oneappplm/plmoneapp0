module Api
  module V1
    module Entities
      class DisclosureCategoryEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the disclosure category.' }
        expose :title, documentation: { type: 'String', desc: 'Title of the category.' }
        expose :note, documentation: { type: 'String', desc: 'Note associated with the category.' }
        expose :alert_type, documentation: { type: 'String', desc: 'Type of alert associated with the category.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
