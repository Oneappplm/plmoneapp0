module Api
  module V1
    module Entities
      class EnrollmentGroupsContactDetailEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the contact detail record.' }
        expose :enrollment_group_id, documentation: { type: 'Integer', desc: 'ID of the associated EnrollmentGroup.' }
        expose :group_personnel_name, documentation: { type: 'String', desc: 'Name of the group personnel.' }
        expose :group_personnel_email, documentation: { type: 'String', desc: 'Email of the group personnel.' }
        expose :group_personnel_phone_number, documentation: { type: 'String', desc: 'Phone number of the group personnel.' }
        expose :group_personnel_fax_number, documentation: { type: 'String', desc: 'Fax number of the group personnel.' }
        expose :group_personnel_position, documentation: { type: 'String', desc: 'Position of the group personnel.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
