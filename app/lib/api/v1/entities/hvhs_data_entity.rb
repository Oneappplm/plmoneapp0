module Api
  module V1
    module Entities
      class HvhsDataEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the HVHS data record.' }
        expose :npi, documentation: { type: 'String', desc: 'NPI number.' }
        expose :first_name, documentation: { type: 'String', desc: 'First name.' }
        expose :middle_name, documentation: { type: 'String', desc: 'Middle name.' }
        expose :last_name, documentation: { type: 'String', desc: 'Last name.' }
        expose :degree_titles, documentation: { type: 'String', desc: 'Degree titles.' }
        expose :office_address_line1, documentation: { type: 'String', desc: 'Office address line 1.' }
        expose :office_address_line2, documentation: { type: 'String', desc: 'Office address line 2.' }
        expose :office_city, documentation: { type: 'String', desc: 'Office city.' }
        expose :office_state, documentation: { type: 'String', desc: 'Office state.' }
        expose :office_zip_code, documentation: { type: 'String', desc: 'Office zip code.' }
        expose :phone_number, documentation: { type: 'String', desc: 'Phone number.' }
        expose :practice_email_address, documentation: { type: 'String', desc: 'Practice email address.' }
        expose :office_mgr_email, documentation: { type: 'String', desc: 'Office manager email.' }
        expose :office_mgr_fax, documentation: { type: 'String', desc: 'Office manager fax.' }
        expose :office_mgr_first_name, documentation: { type: 'String', desc: 'Office manager first name.' }
        expose :office_mgr_last_name, documentation: { type: 'String', desc: 'Office manager last name.' }
        expose :office_mgr_phone, documentation: { type: 'String', desc: 'Office manager phone.' }
        expose :special_type, documentation: { type: 'String', desc: 'Special type.' }
        expose :taxonomy_code, documentation: { type: 'String', desc: 'Taxonomy code.' }
        expose :license_number, documentation: { type: 'String', desc: 'License number.' }
        expose :license_state, documentation: { type: 'String', desc: 'License state.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
