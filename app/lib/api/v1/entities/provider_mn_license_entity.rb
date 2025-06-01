module Api
  module V1
    module Entities
      class ProviderMnLicenseEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the MN license record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :mn_license_number, documentation: { type: 'String', desc: 'MN license number.' }
        expose :mn_license_expiration_date, documentation: { type: 'DateTime', desc: 'MN license expiration date.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
