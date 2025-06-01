module Api
  module V1
    module Entities
      class ProviderDeaLicenseEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the DEA license record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :state_id, documentation: { type: 'Integer', desc: 'ID of the associated State.' }
        expose :dea_license_number, documentation: { type: 'String', desc: 'DEA license number.' }
        expose :dea_license_effective_date, documentation: { type: 'DateTime', desc: 'DEA license effective date.' }
        expose :dea_license_expiration_date, documentation: { type: 'DateTime', desc: 'DEA license expiration date.' }
        expose :dea_license_renewal_effective_date, documentation: { type: 'String', desc: 'DEA license renewal effective date.' }
        expose :no_dea_license, documentation: { type: 'String', desc: 'Indicator if no DEA license.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
