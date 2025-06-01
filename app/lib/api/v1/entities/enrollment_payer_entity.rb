module Api
  module V1
    module Entities
      class EnrollmentPayerEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the enrollment payer.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the enrollment payer.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
