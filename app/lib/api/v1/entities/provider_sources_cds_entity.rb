module Api
  module V1
    module Entities
      class ProviderSourcesCdsEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the CDS record.' }
        expose :provider_source_id, documentation: { type: 'Integer', desc: 'ID of the associated ProviderSource.' }
        expose :registration_number, documentation: { type: 'String', desc: 'CDS registration number.' }
        expose :state, documentation: { type: 'String', desc: 'State associated with the CDS license.' }
        expose :issue_date, documentation: { type: 'DateTime', desc: 'CDS license issue date.' }
        expose :expiration_date, documentation: { type: 'DateTime', desc: 'CDS license expiration date.' }
        expose :practicing_in_state, documentation: { type: 'String', desc: 'Indicator if practicing in state.' }
        expose :full_schedule, documentation: { type: 'String', desc: 'Full schedule indicator.' }
        expose :no_cds_explanation, documentation: { type: 'String', desc: 'Explanation if no CDS license.' } # Changed type to String
        expose :schedule_limit_explanation, documentation: { type: 'String', desc: 'Explanation for schedule limits.' } # Changed type to String
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
