module Api
  module V1
    module Entities
      class ProviderPaLicenseEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the PA license record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :state_id, documentation: { type: 'Integer', desc: 'ID of the associated State.' }
        expose :pa_license_number, documentation: { type: 'String', desc: 'PA license number.' }
        expose :no_pa_license, documentation: { type: 'String', desc: 'Indicator if no PA license.' }
        expose :pa_license_effective_date, documentation: { type: 'DateTime', desc: 'PA license effective date.' }
        expose :pa_license_expiration_date, documentation: { type: 'DateTime', desc: 'PA license expiration date.' }
        expose :pa_license_renewal_effective_date, documentation: { type: 'DateTime', desc: 'PA license renewal effective date.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
