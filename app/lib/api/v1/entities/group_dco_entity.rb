module Api
  module V1
    module Entities
      class GroupDcoEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the Group DCO record.' }
        expose :enrollment_group_id, documentation: { type: 'Integer', desc: 'ID of the associated Enrollment Group.' }
        expose :client, documentation: { type: 'String', desc: 'Client name/identifier.' }
        expose :dco_name, documentation: { type: 'String', desc: 'DCO name.' }
        expose :dco_address, documentation: { type: 'String', desc: 'DCO address.' }
        expose :dco_city, documentation: { type: 'String', desc: 'DCO city.' }
        expose :state, documentation: { type: 'String', desc: 'DCO state.' }
        expose :dco_zipcode, documentation: { type: 'String', desc: 'DCO zipcode.' }
        expose :county, documentation: { type: 'String', desc: 'DCO county.' }
        expose :service_location_phone_number, documentation: { type: 'String', desc: 'Service location phone number.' }
        expose :service_location_fax_number, documentation: { type: 'String', desc: 'Service location fax number.' }
        expose :panel_status_to_new_patients, documentation: { type: 'String', desc: 'Panel status for new patients.' }
        expose :panel_age_limit, documentation: { type: 'String', desc: 'Panel age limit.' }
        expose :include_in_directory, documentation: { type: 'String', desc: 'Include in directory status.' }
        expose :dco_provider_name, documentation: { type: 'String', desc: 'DCO provider contact name.' }
        expose :dco_provider_email, documentation: { type: 'String', desc: 'DCO provider contact email.' }
        expose :dco_provider_phone_number, documentation: { type: 'String', desc: 'DCO provider contact phone.' }
        expose :dco_provider_fax_number, documentation: { type: 'String', desc: 'DCO provider contact fax.' }
        expose :dco_provider_position, documentation: { type: 'String', desc: 'DCO provider contact position.' }
        expose :inpatient_facility, documentation: { type: 'String', desc: 'Inpatient facility status.' }
        expose :is_clinic, documentation: { type: 'String', desc: 'Is clinic status.' }
        expose :telehealth_provider, documentation: { type: 'String', desc: 'Telehealth provider status.' }
        expose :old_address, documentation: { type: 'String', desc: 'Old address.' }
        expose :old_city, documentation: { type: 'String', desc: 'Old city.' }
        expose :old_state, documentation: { type: 'String', desc: 'Old state.' }
        expose :old_county, documentation: { type: 'String', desc: 'Old county.' }
        expose :old_zipcode, documentation: { type: 'String', desc: 'Old zipcode.' }
        expose :is_old_location_primary, documentation: { type: 'Boolean', desc: 'Was old location primary?' }
        expose :website, documentation: { type: 'String', desc: 'Website URL.' }
        expose :tax_id, documentation: { type: 'String', desc: 'Tax ID.' }
        expose :facility_billing_npi, documentation: { type: 'String', desc: 'Facility billing NPI.' }
        expose :mn_medicaid_number, documentation: { type: 'String', desc: 'MN Medicaid number.' }
        expose :wi_medicaid_number, documentation: { type: 'String', desc: 'WI Medicaid number.' }
        expose :medicare_id_ptan, documentation: { type: 'String', desc: 'Medicare ID/PTAN.' }
        expose :taxonomy, documentation: { type: 'String', desc: 'Taxonomy code.' }
        expose :telehealth_video_conferencing_technology, documentation: { type: 'String', desc: 'Telehealth video technology.' }
        expose :is_gender_affirming_treatment, documentation: { type: 'String', desc: 'Provides gender affirming treatment status.' }
        expose :panel_size, documentation: { type: 'String', desc: 'Panel size.' }
        expose :medicare_authorized_official, documentation: { type: 'String', desc: 'Medicare authorized official.' }
        expose :collab_name, documentation: { type: 'String', desc: 'Collaborator name.' }
        expose :collab_npi, documentation: { type: 'String', desc: 'Collaborator NPI.' }
        expose :is_primary_location, documentation: { type: 'Boolean', desc: 'Is this the primary location?' }
        expose :effective_date, documentation: { type: 'Date', desc: 'Effective date.' }
        expose :location_status, documentation: { type: 'String', desc: 'Location status.' }
        expose :location_npi, documentation: { type: 'String', desc: 'Location NPI.' }
        expose :location_tin, documentation: { type: 'String', desc: 'Location TIN.' }
        expose :npi_digits, documentation: { type: 'String', desc: 'NPI digits info.' }
        expose :tin_digits_type, documentation: { type: 'String', desc: 'TIN digits type.' }
        expose :specialty, documentation: { type: 'String', desc: 'Specialty.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
