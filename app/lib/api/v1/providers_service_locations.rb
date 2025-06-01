module Api
  module V1
    class ProvidersServiceLocations < Grape::API

      helpers do
        params :shared_service_location_params do
          optional :primary_service_non_office_area, type: String
          optional :primary_service_location_apps, type: String
          optional :primary_service_zip_code, type: String
          optional :primary_service_office_email, type: String
          optional :primary_service_fax, type: String
          optional :primary_service_office_website, type: String
          optional :primary_service_crisis_phone, type: String
          optional :primary_service_location_other_phone, type: String
          optional :primary_service_appt_scheduling, type: String
          optional :primary_service_interpreter_language, type: String
          optional :primary_service_telehealth_only_state, type: String
        end
      end

      resource :providers_service_locations do

        # GET /api/v1/providers_service_locations
        desc "Return a list of provider service locations"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
        end
        get do
          locations = ProvidersServiceLocation.all
          locations = locations.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          present locations, with: Api::V1::Entities::ProvidersServiceLocationEntity
        end

        # POST /api/v1/providers_service_locations
        desc "Create a provider service location record"
        params do
          use :shared_service_location_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
        end
        post do
          location_params = declared(params, include_missing: false)
          location = ProvidersServiceLocation.new(location_params)

          if location.save
            present location, with: Api::V1::Entities::ProvidersServiceLocationEntity
          else
            error!({ errors: location.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/providers_service_locations/:id
          desc "Return a specific provider service location record"
          get do
            location = ProvidersServiceLocation.find(params[:id])
            present location, with: Api::V1::Entities::ProvidersServiceLocationEntity
          end

          # PUT /api/v1/providers_service_locations/:id
          desc "Update a provider service location record"
          params do
            use :shared_service_location_params
          end
          put do
            location = ProvidersServiceLocation.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if location.update(update_params)
              present location, with: Api::V1::Entities::ProvidersServiceLocationEntity
            else
              error!({ errors: location.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/providers_service_locations/:id
          desc "Delete a provider service location record"
          delete do
            location = ProvidersServiceLocation.find(params[:id])
            if location.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider service location record"] }, 500)
            end
          end

        end
      end
    end
  end
end
