module Api
  module V1
    module Entities
      class ProviderBoardCertificationEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the certification record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :bc_board_certification, documentation: { type: 'String', desc: 'Board certification status/info.' }
        expose :bc_board_name, documentation: { type: 'String', desc: 'Name of the certifying board.' }
        expose :bc_certification_number, documentation: { type: 'String', desc: 'Certification number.' }
        expose :bc_specialty_type, documentation: { type: 'String', desc: 'Type of specialty.' }
        expose :bc_effective_date, documentation: { type: 'DateTime', desc: 'Certification effective date.' }
        expose :bc_expiration_date, documentation: { type: 'DateTime', desc: 'Certification expiration date.' }
        expose :bc_recertification_date, documentation: { type: 'DateTime', desc: 'Recertification date.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
