module Api
  module V1
    module Entities
      class ProviderCdsLicenseEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the CDS license record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :state_id, documentation: { type: 'Integer', desc: 'ID of the associated State.' }
        expose :cds_license_number, documentation: { type: 'String', desc: 'CDS license number.' }
        expose :no_cds_license, documentation: { type: 'String', desc: 'Indicator if no CDS license.' }
        expose :cds_license_issue_date, documentation: { type: 'DateTime', desc: 'CDS license issue date.' }
        expose :cds_license_expiration_date, documentation: { type: 'DateTime', desc: 'CDS license expiration date.' }
        expose :cds_renewal_effective_date, documentation: { type: 'DateTime', desc: 'CDS renewal effective date.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
