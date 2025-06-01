# app/lib/api/v1/entities/client_entity.rb

module Api
  module V1
    module Entities
      class ClientEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the client.' }
        expose :full_name, documentation: { type: 'String', desc: 'Client full name.' }
        expose :first_name, documentation: { type: 'String', desc: 'Client first name.' }
        expose :middle_name, documentation: { type: 'String', desc: 'Client middle name.' }
        expose :last_name, documentation: { type: 'String', desc: 'Client last name.' }
        expose :provider_name, documentation: { type: 'String', desc: 'Associated provider name.' }
        expose :birth_date, documentation: { type: 'Date', desc: 'Client date of birth.' }
        expose :state, documentation: { type: 'String', desc: 'Client state.' }
        expose :state_abbr, documentation: { type: 'String', desc: 'Client state abbreviation.' }
        expose :street_address, documentation: { type: 'String', desc: 'Client street address.' }
        expose :city, documentation: { type: 'String', desc: 'Client city.' }
        expose :zipcode, documentation: { type: 'String', desc: 'Client zipcode.' }
        expose :attested_date, documentation: { type: 'Date', desc: 'Date attested.' }
        expose :npi, documentation: { type: 'String', desc: 'Client NPI number.' }
        expose :ssn, documentation: { type: 'String', desc: 'Client Social Security Number (Sensitive).' }
        expose :provider_type, documentation: { type: 'String', desc: 'Client provider type.' }
        expose :specialty, documentation: { type: 'String', desc: 'Client specialty.' }
        expose :tin, documentation: { type: 'String', desc: 'Client Taxpayer Identification Number (Sensitive).' }
        expose :entity, documentation: { type: 'String', desc: 'Client entity type.' }
        expose :cred_status, documentation: { type: 'String', desc: 'Credentialing status.' }
        expose :cred_cycle, documentation: { type: 'String', desc: 'Credentialing cycle.' }
        expose :vrc_status, documentation: { type: 'String', desc: 'VRC status.' }
        expose :psv_flat, documentation: { type: 'String', desc: 'PSV flat info.' }
        expose :medv_id, documentation: { type: 'String', desc: 'Internal MedV ID.' }
        expose :title, documentation: { type: 'String', desc: 'Client title.' }
        expose :prefix, documentation: { type: 'String', desc: 'Client prefix.' }
        expose :suffix, documentation: { type: 'String', desc: 'Client suffix.' }
        expose :gender, documentation: { type: 'String', desc: 'Client gender.' }
        expose :prac_type, documentation: { type: 'String', desc: 'Practice type.' }
        expose :specialty_name, documentation: { type: 'String', desc: 'Specialty name.' }
        expose :address1, documentation: { type: 'String', desc: 'Address line 1.' }
        expose :address2, documentation: { type: 'String', desc: 'Address line 2.' }
        expose :state_or_province, documentation: { type: 'String', desc: 'State or province.' }
        expose :country, documentation: { type: 'String', desc: 'Country.' }
        expose :postal_code, documentation: { type: 'String', desc: 'Postal code.' }
        expose :primary_phone, documentation: { type: 'String', desc: 'Primary phone number.' }
        expose :primary_email, documentation: { type: 'String', desc: 'Primary email address.' }
        expose :client_specified_id, documentation: { type: 'String', desc: 'Client-specified ID.' }
        expose :practitioner_guid, documentation: { type: 'String', desc: 'Practitioner GUID.' }
        expose :client_guid, documentation: { type: 'String', desc: 'Client GUID.' }
        expose :file_path, documentation: { type: 'String', desc: 'Associated file path.' }
        expose :signature_date, documentation: { type: 'String', desc: 'Signature date.' }
        expose :file_status, documentation: { type: 'String', desc: 'File status.' }
        expose :app_receive_date, documentation: { type: 'String', desc: 'Application received date.' }
        expose :app_receive_complete_date, documentation: { type: 'String', desc: 'Application receive complete date.' }
        expose :app_complete_date, documentation: { type: 'String', desc: 'Application complete date.' }
        expose :approval_date, documentation: { type: 'String', desc: 'Approval date.' }
        expose :cred_or_recred, documentation: { type: 'String', desc: 'Credentialing or recredentialing indicator.' }
        expose :org_type, documentation: { type: 'String', desc: 'Organization type.' }
        expose :caqhid, documentation: { type: 'String', desc: 'CAQH ID.' }
        expose :import_exid, documentation: { type: 'String', desc: 'Import External ID.' }
        expose :client_id, documentation: { type: 'String', desc: 'Client ID.' }
        expose :external_id, documentation: { type: 'String', desc: 'External ID.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the client was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the client was last updated.' }
      end
    end
  end
end
