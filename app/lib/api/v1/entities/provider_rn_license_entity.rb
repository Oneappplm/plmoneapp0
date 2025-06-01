module Api
  module V1
    module Entities
      class ProviderRnLicenseEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the RN license record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :state_id, documentation: { type: 'Integer', desc: 'ID of the associated State.' }
        expose :rn_license_number, documentation: { type: 'String', desc: 'RN license number.' }
        expose :no_rn_license, documentation: { type: 'String', desc: 'Indicator if no RN license.' }
        expose :rn_license_effective_date, documentation: { type: 'Date', desc: 'RN license effective date.' }
        expose :rn_license_expiration_date, documentation: { type: 'Date', desc: 'RN license expiration date.' }
        expose :rn_license_renewal_effective_date, documentation: { type: 'String', desc: 'RN license renewal effective date.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
