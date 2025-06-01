module Api
  module V1
    module Entities
      class GroupRoleEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the group role.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the group role.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the group role was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the group role was last updated.' }
      end
    end
  end
end
