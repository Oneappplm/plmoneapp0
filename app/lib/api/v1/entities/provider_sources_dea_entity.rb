module Api
  module V1
    module Entities
      class ProviderSourcesDeaEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the DEA record.' }
        expose :provider_source_id, documentation: { type: 'Integer', desc: 'ID of the associated ProviderSource.' }
        expose :registration_number, documentation: { type: 'String', desc: 'DEA registration number.' }
        expose :state, documentation: { type: 'String', desc: 'State associated with the DEA license.' }
        expose :issue_date, documentation: { type: 'Date', desc: 'DEA license issue date.' }
        expose :expiration_date, documentation: { type: 'Date', desc: 'DEA license expiration date.' }
        expose :full_schedule, documentation: { type: 'String', desc: 'Full schedule indicator.' }
        expose :does_not_expire, documentation: { type: 'String', desc: 'Indicator if license does not expire.' }
        expose :schedule_limit_explanation, documentation: { type: 'String', desc: 'Explanation for schedule limits.' }
        expose :schedule_helds, documentation: { type: 'String', desc: 'Schedules held.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
