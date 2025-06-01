module Api
  module V1
    module Entities
      class HospitalEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the hospital.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the hospital.' }
        expose :address, documentation: { type: 'String', desc: 'Address of the hospital.' }
        expose :phone, documentation: { type: 'String', desc: 'Phone number of the hospital.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the hospital was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the hospital was last updated.' }
      end
    end
  end
end
