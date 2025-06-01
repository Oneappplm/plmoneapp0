module Api
  module V1
    module Entities
      class ClientOrganizationEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the client organization.' }
        expose :organization_name, documentation: { type: 'String', desc: 'Name of the organization.' }
        expose :organization_type, documentation: { type: 'String', desc: 'Type of the organization.' }
        expose :organization_npi, documentation: { type: 'String', desc: 'Organization NPI number.' }
        expose :organization_address_1, documentation: { type: 'String', desc: 'Organization address line 1.' }
        expose :organization_address_2, documentation: { type: 'String', desc: 'Organization address line 2.' }
        expose :organization_city, documentation: { type: 'String', desc: 'Organization city.' }
        expose :organization_state_id, documentation: { type: 'Integer', desc: 'ID of the organization state.' }
        expose :organization_zipcode, documentation: { type: 'String', desc: 'Organization zipcode.' }
        expose :organization_phone_number, documentation: { type: 'String', desc: 'Organization phone number.' }
        expose :organization_fax_number, documentation: { type: 'String', desc: 'Organization fax number.' }
        expose :organization_dba_name, documentation: { type: 'String', desc: 'Organization DBA name.' }
        expose :organization_tax_id, documentation: { type: 'String', desc: 'Organization Tax ID (Sensitive).' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
