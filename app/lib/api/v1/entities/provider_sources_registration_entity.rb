module Api
  module V1
    module Entities
      class ProviderSourcesRegistrationEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the registration record.' }
        expose :provider_source_id, documentation: { type: 'Integer', desc: 'ID of the associated ProviderSource.' }
        expose :registration_number, documentation: { type: 'String', desc: 'Registration number.' }
        expose :specialty, documentation: { type: 'String', desc: 'Specialty associated with the registration.' }
        expose :issue_state, documentation: { type: 'String', desc: 'State that issued the registration.' }
        expose :issuing_board, documentation: { type: 'String', desc: 'Board that issued the registration.' }
        expose :address_line_1, documentation: { type: 'String', desc: 'Address line 1 for the registration.' }
        expose :address_line_2, documentation: { type: 'String', desc: 'Address line 2 for the registration.' }
        expose :city, documentation: { type: 'String', desc: 'City for the registration.' }
        expose :registration_state, documentation: { type: 'String', desc: 'State for the registration address.' }
        expose :zip_code, documentation: { type: 'String', desc: 'Zip code for the registration address.' }
        expose :telephone_number, documentation: { type: 'String', desc: 'Telephone number associated with the registration.' }
        expose :ext, documentation: { type: 'String', desc: 'Telephone extension.' }
        expose :fax_number, documentation: { type: 'String', desc: 'Fax number associated with the registration.' }
        expose :issue_date, documentation: { type: 'DateTime', desc: 'Date the registration was issued.' }
        expose :expiration_date, documentation: { type: 'DateTime', desc: 'Date the registration expires.' }
        expose :does_not_expire, documentation: { type: 'String', desc: 'Indicator if the registration does not expire.' }
        expose :practicing_under_number, documentation: { type: 'String', desc: 'Indicator if practicing under this number.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
