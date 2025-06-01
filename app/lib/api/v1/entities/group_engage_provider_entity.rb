module Api
  module V1
    module Entities
      class GroupEngageProviderEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the group engage provider record.' }
        expose :practice_location_id, documentation: { type: 'Integer', desc: 'ID of the associated PracticeLocation.' }
        expose :user_id, documentation: { type: 'Integer', desc: 'ID of the associated User.' }
        expose :first_name, documentation: { type: 'String', desc: 'First name.' }
        expose :middle_name, documentation: { type: 'String', desc: 'Middle name.' }
        expose :last_name, documentation: { type: 'String', desc: 'Last name.' }
        expose :date_of_birth, documentation: { type: 'DateTime', desc: 'Date of birth.' }
        expose :email_address, documentation: { type: 'String', desc: 'Email address.' }
        expose :ssn, documentation: { type: 'String', desc: 'Social Security Number (Sensitive).' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
