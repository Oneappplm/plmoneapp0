module Api
  module V1
    class PracticeLocations < Grape::API

      helpers do
        params :shared_practice_location_params do
          optional :location, type: String, desc: 'Location identifier/name.'
          optional :legal_name, type: String, desc: 'Legal name of the practice at this location.'
          optional :address1, type: String, desc: 'Address line 1.'
          optional :address2, type: String, desc: 'Address line 2.'
          optional :city, type: String, desc: 'City.'
          optional :state_id, type: String, desc: 'Associated State ID.'
          optional :zip_code, type: String, desc: 'Zip code.'
          optional :phone_number, type: String, desc: 'Primary phone number.'
          optional :fax_number, type: String, desc: 'Fax number.'
          optional :email, type: String, desc: 'Email address.'
          optional :group_tax_number, type: String, desc: 'Group tax number (Sensitive?).'
          optional :group_npi_number, type: String, desc: 'Group NPI number.'
          optional :have_group_tax_number, type: Boolean, desc: 'Flag indicating if group tax number exists.'
          optional :group_npi_number_effective_date, type: DateTime, desc: 'Group NPI effective date.'
          optional :languages_speak, type: String, desc: 'Languages spoken.'
          optional :languages_write, type: String, desc: 'Languages written.'
          optional :interpreters_available, type: String, desc: 'Interpreter availability.'
          optional :contact_first_name, type: String, desc: 'Contact first name.'
          optional :contact_middle_name, type: String, desc: 'Contact middle name.'
          optional :contact_last_name, type: String, desc: 'Contact last name.'
          optional :contact_suffix, type: String, desc: 'Contact suffix.'
          optional :contact_title, type: String, desc: 'Contact title.'
          optional :contact_phone_number, type: String, desc: 'Contact phone number.'
          optional :contact_ext, type: String, desc: 'Contact phone extension.'
          optional :contact_fax_number, type: String, desc: 'Contact fax number.'
          optional :contact_email, type: String, desc: 'Contact email.'
          optional :monday_time_start, type: Time, desc: 'Monday start time.'
          optional :monday_time_end, type: Time, desc: 'Monday end time.'
          optional :monday_split_day, type: Boolean, desc: 'Monday split day flag.'
          optional :monday_closed, type: Boolean, desc: 'Monday closed flag.'
          optional :tuesday_time_start, type: Time, desc: 'Tuesday start time.'
          optional :tuesday_time_end, type: Time, desc: 'Tuesday end time.'
          optional :tuesday_split_day, type: Boolean, desc: 'Tuesday split day flag.'
          optional :tuesday_closed, type: Boolean, desc: 'Tuesday closed flag.'
          optional :wednesday_time_start, type: Time, desc: 'Wednesday start time.'
          optional :wednesday_time_end, type: Time, desc: 'Wednesday end time.'
          optional :wednesday_split_day, type: Boolean, desc: 'Wednesday split day flag.'
          optional :wednesday_closed, type: Boolean, desc: 'Wednesday closed flag.'
          optional :thursday_time_start, type: Time, desc: 'Thursday start time.'
          optional :thursday_time_end, type: Time, desc: 'Thursday end time.'
          optional :thursday_split_day, type: Boolean, desc: 'Thursday split day flag.'
          optional :thursday_closed, type: Boolean, desc: 'Thursday closed flag.'
          optional :friday_time_start, type: Time, desc: 'Friday start time.'
          optional :friday_time_end, type: Time, desc: 'Friday end time.'
          optional :friday_split_day, type: Boolean, desc: 'Friday split day flag.'
          optional :friday_closed, type: Boolean, desc: 'Friday closed flag.'
          optional :saturday_time_start, type: Time, desc: 'Saturday start time.'
          optional :saturday_time_end, type: Time, desc: 'Saturday end time.'
          optional :saturday_split_day, type: Boolean, desc: 'Saturday split day flag.'
          optional :saturday_closed, type: Boolean, desc: 'Saturday closed flag.'
          optional :sunday_time_start, type: Time, desc: 'Sunday start time.'
          optional :sunday_time_end, type: Time, desc: 'Sunday end time.'
          optional :sunday_split_day, type: Boolean, desc: 'Sunday split day flag.'
          optional :sunday_closed, type: Boolean, desc: 'Sunday closed flag.'
          optional :comment, type: String, desc: 'General comment.'
          optional :telephone_coverage, type: String, desc: 'Telephone coverage info.'
          optional :telephone_coverage_type, type: String, desc: 'Type of telephone coverage.'
          optional :telephone_number_after_hours, type: String, desc: 'After hours phone number.'
          optional :telephone_number_ext, type: String, desc: 'After hours phone extension.'
          optional :pa_practice_status, type: String, desc: 'PA practice status.'
          optional :pa_by_health_plan, type: String, desc: 'PA by health plan info.'
          optional :pa_limitations, type: String, desc: 'PA limitations.'
          optional :pa_gender_limitations, type: String, desc: 'PA gender limitations.'
          optional :pa_minimum_age, type: Integer, desc: 'PA minimum age.'
          optional :pa_maximum_age, type: Integer, desc: 'PA maximum age.'
          optional :pa_min_max_not_applicable, type: Boolean, desc: 'PA min/max age not applicable flag.'
          optional :pa_other_limitations, type: String, desc: 'Other PA limitations.'
          optional :ada_accessibility, type: String, desc: 'ADA accessibility status.'
          optional :ada_wrp, type: String, desc: 'ADA WRP info.'
          optional :disabled_other_services, type: String, desc: 'Other services for disabled.'
          optional :disabled_other_services_wrp, type: String, desc: 'Disabled other services WRP info.'
          optional :public_transportation, type: String, desc: 'Public transportation availability.'
          optional :public_transportation_wrp, type: String, desc: 'Public transportation WRP info.'
          optional :laboratory_services, type: String, desc: 'Laboratory services availability.'
          optional :laboratory_services_wrp, type: String, desc: 'Laboratory services WRP info.'
          optional :clia_waiver, type: String, desc: 'CLIA waiver status.'
          optional :clia_waiver_wrp, type: String, desc: 'CLIA waiver WRP info.'
          optional :clia_waiver_expiration_date, type: String, desc: 'CLIA waiver expiration date.'
          optional :clia_certificate, type: String, desc: 'CLIA certificate status.'
          optional :clia_certificate_wrp, type: String, desc: 'CLIA certificate WRP info.'
          optional :clia_certificate_expiration_date, type: String, desc: 'CLIA certificate expiration date.'
          optional :radiology_services, type: String, desc: 'Radiology services availability.'
          optional :radiology_services_xray, type: String, desc: 'Radiology X-Ray services info.'
          optional :radiology_services_fda, type: String, desc: 'Radiology FDA info.'
          optional :anesthesia_administered, type: String, desc: 'Anesthesia administered info.'
          optional :additional_procedures, type: String, desc: 'Additional procedures info.'
        end
      end

      resource :practice_locations do

        # GET /api/v1/practice_locations
        desc "Return a list of practice locations"
        params do
          optional :location, type: String, desc: "Filter by location name/identifier."
          optional :city, type: String, desc: "Filter by city."
          optional :state_id, type: String, desc: "Filter by state ID."
        end
        get do
          locations = PracticeLocation.all
          locations = locations.where(location: params[:location]) if params[:location].present?
          locations = locations.where(city: params[:city]) if params[:city].present?
          locations = locations.where(state_id: params[:state_id]) if params[:state_id].present?
          present locations, with: Api::V1::Entities::PracticeLocationEntity
        end

        # POST /api/v1/practice_locations
        desc "Create a practice location"
        params do
          use :shared_practice_location_params
        end
        post do
          location_params = declared(params, include_missing: false)
          location = PracticeLocation.new(location_params)

          if location.save
            present location, with: Api::V1::Entities::PracticeLocationEntity
          else
            error!({ errors: location.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/practice_locations/:id
          desc "Return a specific practice location"
          get do
            location = PracticeLocation.find(params[:id])
            present location, with: Api::V1::Entities::PracticeLocationEntity
          end

          # PUT /api/v1/practice_locations/:id
          desc "Update a practice location"
          params do
            use :shared_practice_location_params
          end
          put do
            location = PracticeLocation.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if location.update(update_params)
              present location, with: Api::V1::Entities::PracticeLocationEntity
            else
              error!({ errors: location.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/practice_locations/:id
          desc "Delete a practice location"
          delete do
            location = PracticeLocation.find(params[:id])
            if location.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete practice location"] }, 500)
            end
          end

        end
      end
    end
  end
end
