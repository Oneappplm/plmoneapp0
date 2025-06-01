module Api
  module V1
    module Entities
      class ProviderLicenseEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the license record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :state_id, documentation: { type: 'Integer', desc: 'ID of the associated State.' }
        expose :license_number, documentation: { type: 'String', desc: 'License number.' }
        expose :license_effective_date, documentation: { type: 'Date', desc: 'License effective date.' }
        expose :license_expiration_date, documentation: { type: 'Date', desc: 'License expiration date.' }
        expose :license_state_renewal_date, documentation: { type: 'String', desc: 'License state renewal date.' } # Consider Date type
        expose :no_state_license, documentation: { type: 'String', desc: 'Indicator if no state license.' }
        expose :license_type, documentation: { type: 'String', desc: 'Type of license.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
