module Api
  module V1
    module Entities
      class DirectoryEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the directory.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the directory.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
