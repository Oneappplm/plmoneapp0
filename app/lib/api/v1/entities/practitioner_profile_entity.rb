module Api
  module V1
    module Entities
      class PractitionerProfileEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the practitioner profile.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated provider.' }
        expose :bio, documentation: { type: 'String', desc: 'Practitioner biography.' }
        expose :website, documentation: { type: 'String', desc: 'Practitioner website.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the profile was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the profile was last updated.' }
      end
    end
  end
end
