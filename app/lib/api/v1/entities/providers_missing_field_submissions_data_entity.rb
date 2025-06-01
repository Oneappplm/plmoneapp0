module Api
  module V1
    module Entities
      class ProvidersMissingFieldSubmissionsDataEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the data record.' }
        expose :providers_missing_field_submission_id, documentation: { type: 'Integer', desc: 'ID of the parent ProvidersMissingFieldSubmission.' }
        expose :data_attribute, documentation: { type: 'String', desc: 'The attribute name of the missing field.' }
        expose :data_key, documentation: { type: 'String', desc: 'A key related to the data (if applicable).' }
        expose :data_value, documentation: { type: 'String', desc: 'The submitted value for the missing field.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
