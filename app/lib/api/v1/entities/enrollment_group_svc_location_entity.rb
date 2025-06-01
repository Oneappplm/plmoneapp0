module Api
  module V1
    module Entities
      class EnrollmentGroupSvcLocationEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the service location record.' }
        expose :enrollment_group_id, documentation: { type: 'Integer', desc: 'ID of the associated EnrollmentGroup.' }
        expose :primary_service_non_office_area, documentation: { type: 'String', desc: 'Primary service non-office area info.' }
        expose :primary_service_location_apps, documentation: { type: 'String', desc: 'Primary service location applications info.' }
        expose :primary_service_zip_code, documentation: { type: 'String', desc: 'Primary service zip code.' }
        expose :primary_service_office_email, documentation: { type: 'String', desc: 'Primary service office email.' }
        expose :primary_service_fax, documentation: { type: 'String', desc: 'Primary service fax number.' }
        expose :primary_service_office_website, documentation: { type: 'String', desc: 'Primary service office website.' }
        expose :primary_service_crisis_phone, documentation: { type: 'String', desc: 'Primary service crisis phone number.' }
        expose :primary_service_location_other_phone, documentation: { type: 'String', desc: 'Primary service location other phone number.' }
        expose :primary_service_appt_scheduling, documentation: { type: 'String', desc: 'Primary service appointment scheduling info.' }
        expose :primary_service_interpreter_language, documentation: { type: 'String', desc: 'Primary service interpreter language info.' }
        expose :primary_service_telehealth_only_state, documentation: { type: 'String', desc: 'Primary service telehealth only state info.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
