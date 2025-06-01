module Api
  module V1
    class ProviderSourcesRegistrations < Grape::API

      helpers do
        params :shared_registration_params do
          optional :registration_number, type: String, desc: 'Registration number.'
          optional :specialty, type: String, desc: 'Specialty associated with the registration.'
          optional :issue_state, type: String, desc: 'State that issued the registration.'
          optional :issuing_board, type: String, desc: 'Board that issued the registration.'
          optional :address_line_1, type: String, desc: 'Address line 1 for the registration.'
          optional :address_line_2, type: String, desc: 'Address line 2 for the registration.'
          optional :city, type: String, desc: 'City for the registration.'
          optional :registration_state, type: String, desc: 'State for the registration address.'
          optional :zip_code, type: String, desc: 'Zip code for the registration address.'
          optional :telephone_number, type: String, desc: 'Telephone number associated with the registration.'
          optional :ext, type: String, desc: 'Telephone extension.'
          optional :fax_number, type: String, desc: 'Fax number associated with the registration.'
          optional :issue_date, type: DateTime, desc: 'Date the registration was issued.'
          optional :expiration_date, type: DateTime, desc: 'Date the registration expires.'
          optional :does_not_expire, type: String, desc: 'Indicator if the registration does not expire.'
          optional :practicing_under_number, type: String, desc: 'Indicator if practicing under this number.'
        end
      end

      resource :provider_sources_registrations do

        # GET /api/v1/provider_sources_registrations
        desc "Return a list of provider source registration records"
        params do
          optional :provider_source_id, type: Integer, desc: "Filter by ProviderSource ID."
          optional :issue_state, type: String, desc: "Filter by issue state."
        end
        get do
          registrations = ProviderSourcesRegistration.all
          registrations = registrations.where(provider_source_id: params[:provider_source_id]) if params[:provider_source_id].present?
          registrations = registrations.where(issue_state: params[:issue_state]) if params[:issue_state].present?
          present registrations, with: Api::V1::Entities::ProviderSourcesRegistrationEntity
        end

        # POST /api/v1/provider_sources_registrations
        desc "Create a provider source registration record"
        params do
          use :shared_registration_params
          requires :provider_source_id, type: Integer, desc: 'ID of the associated ProviderSource.'
        end
        post do
          registration_params = declared(params, include_missing: false)
          registration = ProviderSourcesRegistration.new(registration_params)

          if registration.save
            present registration, with: Api::V1::Entities::ProviderSourcesRegistrationEntity
          else
            error!({ errors: registration.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_sources_registrations/:id
          desc "Return a specific provider source registration record"
          get do
            registration = ProviderSourcesRegistration.find(params[:id])
            present registration, with: Api::V1::Entities::ProviderSourcesRegistrationEntity
          end

          # PUT /api/v1/provider_sources_registrations/:id
          desc "Update a provider source registration record"
          params do
            use :shared_registration_params
          end
          put do
            registration = ProviderSourcesRegistration.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if registration.update(update_params)
              present registration, with: Api::V1::Entities::ProviderSourcesRegistrationEntity
            else
              error!({ errors: registration.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_sources_registrations/:id
          desc "Delete a provider source registration record"
          delete do
            registration = ProviderSourcesRegistration.find(params[:id])
            if registration.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider source registration record"] }, 500)
            end
          end

        end
      end
    end
  end
end
