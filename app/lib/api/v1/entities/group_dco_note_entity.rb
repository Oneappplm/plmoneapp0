module Api
  module V1
    module Entities
      class GroupDcoNoteEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the group dco note record.' }
        expose :group_dco_id, documentation: { type: 'Integer', desc: 'ID of the associated GroupDcoNote.' }
        expose :title, documentation: { type: 'String', desc: 'Title of the group dco note.' }
        expose :description, documentation: { type: 'String', desc: 'Description of the group dco note.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
