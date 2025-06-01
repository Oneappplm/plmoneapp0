module Api
  module V1
    module Entities
      class UserEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique database ID of the user.' }
        expose :email, documentation: { type: 'String', desc: 'User email address.' }
        expose :first_name, documentation: { type: 'String', desc: 'User first name.' }
        expose :middle_name, documentation: { type: 'String', desc: 'User middle name.' }
        expose :last_name, documentation: { type: 'String', desc: 'User last name.' }
        expose :suffix, documentation: { type: 'String', desc: 'User suffix (e.g., Jr., Sr.).' }
        expose :title, documentation: { type: 'String', desc: 'User title (e.g., Mr., Ms., Dr.).' }
        expose :user_type, documentation: { type: 'String', desc: 'Type classification of the user.' }
        expose :user_role, documentation: { type: 'String', desc: 'Role assigned to the user.' }
        expose :status, documentation: { type: 'String', desc: 'Current status of the user account (e.g., active, inactive).' }
      end
    end
  end
end
