module Api
  module V1
    module Entities
      class PracticeLocationEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the practice location.' }
        expose :location, documentation: { type: 'String', desc: 'Location identifier/name.' }
        expose :legal_name, documentation: { type: 'String', desc: 'Legal name of the practice at this location.' }
        expose :address1, documentation: { type: 'String', desc: 'Address line 1.' }
        expose :address2, documentation: { type: 'String', desc: 'Address line 2.' }
        expose :city, documentation: { type: 'String', desc: 'City.' }
        expose :state_id, documentation: { type: 'String', desc: 'Associated State ID.' }
        expose :zip_code, documentation: { type: 'String', desc: 'Zip code.' }
        expose :phone_number, documentation: { type: 'String', desc: 'Primary phone number.' }
        expose :fax_number, documentation: { type: 'String', desc: 'Fax number.' }
        expose :email, documentation: { type: 'String', desc: 'Email address.' }
        expose :group_tax_number, documentation: { type: 'String', desc: 'Group tax number (Sensitive?).' }
        expose :group_npi_number, documentation: { type: 'String', desc: 'Group NPI number.' }
        expose :have_group_tax_number, documentation: { type: 'Boolean', desc: 'Flag indicating if group tax number exists.' }
        expose :group_npi_number_effective_date, documentation: { type: 'DateTime', desc: 'Group NPI effective date.' }
        expose :languages_speak, documentation: { type: 'String', desc: 'Languages spoken.' }
        expose :languages_write, documentation: { type: 'String', desc: 'Languages written.' }
        expose :interpreters_available, documentation: { type: 'String', desc: 'Interpreter availability.' }
        expose :contact_first_name, documentation: { type: 'String', desc: 'Contact first name.' }
        expose :contact_middle_name, documentation: { type: 'String', desc: 'Contact middle name.' }
        expose :contact_last_name, documentation: { type: 'String', desc: 'Contact last name.' }
        expose :contact_suffix, documentation: { type: 'String', desc: 'Contact suffix.' }
        expose :contact_title, documentation: { type: 'String', desc: 'Contact title.' }
        expose :contact_phone_number, documentation: { type: 'String', desc: 'Contact phone number.' }
        expose :contact_ext, documentation: { type: 'String', desc: 'Contact phone extension.' }
        expose :contact_fax_number, documentation: { type: 'String', desc: 'Contact fax number.' }
        expose :contact_email, documentation: { type: 'String', desc: 'Contact email.' }
        expose :monday_time_start, documentation: { type: 'Time', desc: 'Monday start time.' }
        expose :monday_time_end, documentation: { type: 'Time', desc: 'Monday end time.' }
        expose :monday_split_day, documentation: { type: 'Boolean', desc: 'Monday split day flag.' }
        expose :monday_closed, documentation: { type: 'Boolean', desc: 'Monday closed flag.' }
        expose :tuesday_time_start, documentation: { type: 'Time', desc: 'Tuesday start time.' }
        expose :tuesday_time_end, documentation: { type: 'Time', desc: 'Tuesday end time.' }
        expose :tuesday_split_day, documentation: { type: 'Boolean', desc: 'Tuesday split day flag.' }
        expose :tuesday_closed, documentation: { type: 'Boolean', desc: 'Tuesday closed flag.' }
        expose :wednesday_time_start, documentation: { type: 'Time', desc: 'Wednesday start time.' }
        expose :wednesday_time_end, documentation: { type: 'Time', desc: 'Wednesday end time.' }
        expose :wednesday_split_day, documentation: { type: 'Boolean', desc: 'Wednesday split day flag.' }
        expose :wednesday_closed, documentation: { type: 'Boolean', desc: 'Wednesday closed flag.' }
        expose :thursday_time_start, documentation: { type: 'Time', desc: 'Thursday start time.' }
        expose :thursday_time_end, documentation: { type: 'Time', desc: 'Thursday end time.' }
        expose :thursday_split_day, documentation: { type: 'Boolean', desc: 'Thursday split day flag.' }
        expose :thursday_closed, documentation: { type: 'Boolean', desc: 'Thursday closed flag.' }
        expose :friday_time_start, documentation: { type: 'Time', desc: 'Friday start time.' }
        expose :friday_time_end, documentation: { type: 'Time', desc: 'Friday end time.' }
        expose :friday_split_day, documentation: { type: 'Boolean', desc: 'Friday split day flag.' }
        expose :friday_closed, documentation: { type: 'Boolean', desc: 'Friday closed flag.' }
        expose :saturday_time_start, documentation: { type: 'Time', desc: 'Saturday start time.' }
        expose :saturday_time_end, documentation: { type: 'Time', desc: 'Saturday end time.' }
        expose :saturday_split_day, documentation: { type: 'Boolean', desc: 'Saturday split day flag.' }
        expose :saturday_closed, documentation: { type: 'Boolean', desc: 'Saturday closed flag.' }
        expose :sunday_time_start, documentation: { type: 'Time', desc: 'Sunday start time.' }
        expose :sunday_time_end, documentation: { type: 'Time', desc: 'Sunday end time.' }
        expose :sunday_split_day, documentation: { type: 'Boolean', desc: 'Sunday split day flag.' }
        expose :sunday_closed, documentation: { type: 'Boolean', desc: 'Sunday closed flag.' }
        expose :comment, documentation: { type: 'String', desc: 'General comment.' }
        expose :telephone_coverage, documentation: { type: 'String', desc: 'Telephone coverage info.' }
        expose :telephone_coverage_type, documentation: { type: 'String', desc: 'Type of telephone coverage.' }
        expose :telephone_number_after_hours, documentation: { type: 'String', desc: 'After hours phone number.' }
        expose :telephone_number_ext, documentation: { type: 'String', desc: 'After hours phone extension.' }
        expose :pa_practice_status, documentation: { type: 'String', desc: 'PA practice status.' }
        expose :pa_by_health_plan, documentation: { type: 'String', desc: 'PA by health plan info.' }
        expose :pa_limitations, documentation: { type: 'String', desc: 'PA limitations.' }
        expose :pa_gender_limitations, documentation: { type: 'String', desc: 'PA gender limitations.' }
        expose :pa_minimum_age, documentation: { type: 'Integer', desc: 'PA minimum age.' }
        expose :pa_maximum_age, documentation: { type: 'Integer', desc: 'PA maximum age.' }
        expose :pa_min_max_not_applicable, documentation: { type: 'Boolean', desc: 'PA min/max age not applicable flag.' }
        expose :pa_other_limitations, documentation: { type: 'String', desc: 'Other PA limitations.' }
        expose :ada_accessibility, documentation: { type: 'String', desc: 'ADA accessibility status.' }
        expose :ada_wrp, documentation: { type: 'String', desc: 'ADA WRP info.' }
        expose :disabled_other_services, documentation: { type: 'String', desc: 'Other services for disabled.' }
        expose :disabled_other_services_wrp, documentation: { type: 'String', desc: 'Disabled other services WRP info.' }
        expose :public_transportation, documentation: { type: 'String', desc: 'Public transportation availability.' }
        expose :public_transportation_wrp, documentation: { type: 'String', desc: 'Public transportation WRP info.' }
        expose :laboratory_services, documentation: { type: 'String', desc: 'Laboratory services availability.' }
        expose :laboratory_services_wrp, documentation: { type: 'String', desc: 'Laboratory services WRP info.' }
        expose :clia_waiver, documentation: { type: 'String', desc: 'CLIA waiver status.' }
        expose :clia_waiver_wrp, documentation: { type: 'String', desc: 'CLIA waiver WRP info.' }
        expose :clia_waiver_expiration_date, documentation: { type: 'String', desc: 'CLIA waiver expiration date.' } # Consider Date type
        expose :clia_certificate, documentation: { type: 'String', desc: 'CLIA certificate status.' }
        expose :clia_certificate_wrp, documentation: { type: 'String', desc: 'CLIA certificate WRP info.' }
        expose :clia_certificate_expiration_date, documentation: { type: 'String', desc: 'CLIA certificate expiration date.' } # Consider Date type
        expose :radiology_services, documentation: { type: 'String', desc: 'Radiology services availability.' }
        expose :radiology_services_xray, documentation: { type: 'String', desc: 'Radiology X-Ray services info.' }
        expose :radiology_services_fda, documentation: { type: 'String', desc: 'Radiology FDA info.' }
        expose :anesthesia_administered, documentation: { type: 'String', desc: 'Anesthesia administered info.' }
        expose :additional_procedures, documentation: { type: 'String', desc: 'Additional procedures info.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
