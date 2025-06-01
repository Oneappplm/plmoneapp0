module Api
  module V1
    module Entities
      class HelpCodeEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the help code.' }
        expose :code, documentation: { type: 'String', desc: 'Help code identifier.' }
        expose :description, documentation: { type: 'String', desc: 'Help code description.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the help code was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the help code was last updated.' }
      end
    end
  end
end
