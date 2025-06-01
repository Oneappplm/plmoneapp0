module Api
  module V1
    module Entities
      class RoleBasedAccessEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the access rule.' }
        expose :role, documentation: { type: 'String', desc: 'The role string this rule applies to.' }
        expose :page, documentation: { type: 'String', desc: 'The page or resource this rule applies to.' }
        expose :can_create, documentation: { type: 'Boolean', desc: 'Permission to create.' }
        expose :can_read, documentation: { type: 'Boolean', desc: 'Permission to read/view.' }
        expose :can_update, documentation: { type: 'Boolean', desc: 'Permission to update.' }
        expose :can_delete, documentation: { type: 'Boolean', desc: 'Permission to delete.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the rule was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the rule was last updated.' }
      end
    end
  end
end
