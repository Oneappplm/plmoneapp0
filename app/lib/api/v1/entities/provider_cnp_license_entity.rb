module Api
  module V1
    module Entities
      class ProviderCnpLicenseEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the CNP license record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :state_id, documentation: { type: 'Integer', desc: 'ID of the associated State.' }
        expose :cnp_license_number, documentation: { type: 'String', desc: 'CNP license number.' }
        expose :no_cnp_license, documentation: { type: 'String', desc: 'Indicator if no CNP license.' }
        expose :effective_date, documentation: { type: 'DateTime', desc: 'CNP license effective date.' }
        expose :expiration_date, documentation: { type: 'DateTime', desc: 'CNP license expiration date.' }
        expose :cnp_license_renewal_effective_date, documentation: { type: 'DateTime', desc: 'CNP renewal effective date.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
