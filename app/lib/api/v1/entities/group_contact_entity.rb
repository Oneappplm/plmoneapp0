module Api
  module V1
    module Entities
      class GroupContactEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the group contact.' }
        expose :group_dco_id, documentation: { type: 'Integer', desc: 'ID of the associated GroupDco.' }
        expose :enrollment_group_id, documentation: { type: 'Integer', desc: 'ID of the associated EnrollmentGroup.' }
        expose :department, documentation: { type: 'String', desc: 'Department of the contact.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the contact.' }
        expose :role, documentation: { type: 'String', desc: 'Role of the contact.' }
        expose :phone, documentation: { type: 'String', desc: 'Phone number of the contact.' }
        expose :email, documentation: { type: 'String', desc: 'Email address of the contact.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
