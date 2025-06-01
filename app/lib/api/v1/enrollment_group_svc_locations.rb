module Api
  module V1
    class EnrollmentGroupSvcLocations < Grape::API

      helpers do
        params :shared_svc_location_params do
          optional :primary_service_non_office_area, type: String, desc: 'Primary service non-office area info.'
          optional :primary_service_location_apps, type: String, desc: 'Primary service location applications info.'
          optional :primary_service_zip_code, type: String, desc: 'Primary service zip code.'
          optional :primary_service_office_email, type: String, desc: 'Primary service office email.'
          optional :primary_service_fax, type: String, desc: 'Primary service fax number.'
          optional :primary_service_office_website, type: String, desc: 'Primary service office website.'
          optional :primary_service_crisis_phone, type: String, desc: 'Primary service crisis phone number.'
          optional :primary_service_location_other_phone, type: String, desc: 'Primary service location other phone number.'
          optional :primary_service_appt_scheduling, type: String, desc: 'Primary service appointment scheduling info.'
          optional :primary_service_interpreter_language, type: String, desc: 'Primary service interpreter language info.'
          optional :primary_service_telehealth_only_state, type: String, desc: 'Primary service telehealth only state info.'
        end
      end

      resource :enrollment_group_svc_locations do

        # GET /api/v1/enrollment_group_svc_locations
        desc "Return a list of enrollment group service locations"
        params do
          optional :enrollment_group_id, type: Integer, desc: "Filter by EnrollmentGroup ID."
        end
        get do
          locations = EnrollmentGroupSvcLocation.all
          locations = locations.where(enrollment_group_id: params[:enrollment_group_id]) if params[:enrollment_group_id].present?
          present locations, with: Api::V1::Entities::EnrollmentGroupSvcLocationEntity
        end

        # POST /api/v1/enrollment_group_svc_locations
        desc "Create an enrollment group service location"
        params do
          use :shared_svc_location_params
          requires :enrollment_group_id, type: Integer, desc: 'ID of the associated EnrollmentGroup.'
        end
        post do
          location_params = declared(params, include_missing: false)
          location = EnrollmentGroupSvcLocation.new(location_params)

          if location.save
            present location, with: Api::V1::Entities::EnrollmentGroupSvcLocationEntity
          else
            error!({ errors: location.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/enrollment_group_svc_locations/:id
          desc "Return a specific enrollment group service location"
          get do
            location = EnrollmentGroupSvcLocation.find(params[:id])
            present location, with: Api::V1::Entities::EnrollmentGroupSvcLocationEntity
          end

          # PUT /api/v1/enrollment_group_svc_locations/:id
          desc "Update an enrollment group service location"
          params do
            use :shared_svc_location_params
          end
          put do
            location = EnrollmentGroupSvcLocation.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if location.update(update_params)
              present location, with: Api::V1::Entities::EnrollmentGroupSvcLocationEntity
            else
              error!({ errors: location.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/enrollment_group_svc_locations/:id
          desc "Delete an enrollment group service location"
          delete do
            location = EnrollmentGroupSvcLocation.find(params[:id])
            if location.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete enrollment group service location"] }, 500)
            end
          end

        end
      end
    end
  end
end
