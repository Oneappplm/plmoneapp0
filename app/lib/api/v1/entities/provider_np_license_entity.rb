module Api
  module V1
    module Entities
      class ProviderNpLicenseEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the NP license record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :state_id, documentation: { type: 'Integer', desc: 'ID of the associated State.' }
        expose :np_license_number, documentation: { type: 'String', desc: 'NP license number.' }
        expose :no_np_license, documentation: { type: 'String', desc: 'Indicator if no NP license.' }
        expose :np_license_effective_date, documentation: { type: 'Date', desc: 'NP license effective date.' }
        expose :np_license_expiration_date, documentation: { type: 'Date', desc: 'NP license expiration date.' }
        expose :np_license_renewal_effective_date, documentation: { type: 'DateTime', desc: 'NP license renewal effective date.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
