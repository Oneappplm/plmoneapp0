module Api
  module V1
    module Entities
      class WorkHistoryProviderEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the work history record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :practice_name, documentation: { type: 'String', desc: 'Name of the practice.' }
        expose :location, documentation: { type: 'String', desc: 'Location of the practice.' }
        expose :start_date, documentation: { type: 'Date', desc: 'Start date of employment.' }
        expose :end_date, documentation: { type: 'Date', desc: 'End date of employment.' }
        expose :tax_id, documentation: { type: 'Integer', desc: 'Tax ID associated with the practice (Sensitive?).' }
        expose :reasone_of_leaving, documentation: { type: 'String', desc: 'Reason for leaving the practice.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
