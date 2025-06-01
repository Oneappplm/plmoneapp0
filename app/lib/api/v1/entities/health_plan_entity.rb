module Api
  module V1
    module Entities
      class HealthPlanEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the health plan.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the health plan.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the health plan was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the health plan was last updated.' }
      end
    end
  end
end
