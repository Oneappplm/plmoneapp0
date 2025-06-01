module Api
  module V1
    module Entities
      class BoardNameEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the board name.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the board.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the board name was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the board name was last updated.' }
      end
    end
  end
end
