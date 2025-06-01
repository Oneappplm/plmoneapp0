module Api
  module V1
    module Entities
      class PrivilegeStatusEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the privilege status.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the privilege status.' }
        expose :description, documentation: { type: 'String', desc: 'Description of the privilege status.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the privilege status was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the privilege status was last updated.' }
      end
    end
  end
end
