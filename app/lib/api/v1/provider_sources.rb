module Api
  module V1
    class ProviderSources < Grape::API

      helpers do
        params :shared_source_params do
          optional :status, type: String, desc: 'Status of the provider source (e.g., draft, submitted).'
          optional :current_provider_source, type: Boolean, desc: 'Flag indicating if this is the current source.'
          optional :invitation_count, type: Integer, desc: 'Number of invitations sent.'
          optional :invitation_sent_at, type: DateTime, desc: 'Timestamp when the last invitation was sent.'
          optional :practice_location_id, type: Integer, desc: 'ID of the associated PracticeLocation.'
          optional :group_engage_provider_id, type: Integer, desc: 'ID of the associated GroupEngageProvider.'
          optional :created_by_user, type: Integer, desc: 'ID of the User who created this source record.'
        end
      end

      resource :provider_sources do

        # GET /api/v1/provider_sources
        desc "Return a list of provider source records"
        params do
          optional :status, type: String, desc: "Filter by status."
          optional :practice_location_id, type: Integer, desc: "Filter by Practice Location ID."
          optional :created_by_user, type: Integer, desc: "Filter by creator User ID."
        end
        get do
          sources = ProviderSource.all
          sources = sources.where(status: params[:status]) if params[:status].present?
          sources = sources.where(practice_location_id: params[:practice_location_id]) if params[:practice_location_id].present?
          sources = sources.where(created_by_user: params[:created_by_user]) if params[:created_by_user].present?
          present sources, with: Api::V1::Entities::ProviderSourceEntity
        end

        # POST /api/v1/provider_sources
        desc "Create a provider source record"
        params do
          use :shared_source_params
        end
        post do
          source_params = declared(params, include_missing: false)
          source = ProviderSource.new(source_params)

          if source.save
            present source, with: Api::V1::Entities::ProviderSourceEntity
          else
            error!({ errors: source.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_sources/:id
          desc "Return a specific provider source record"
          get do
            source = ProviderSource.find(params[:id])
            present source, with: Api::V1::Entities::ProviderSourceEntity
          end

          # PUT /api/v1/provider_sources/:id
          desc "Update a provider source record"
          params do
            use :shared_source_params
          end
          put do
            source = ProviderSource.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if source.update(update_params)
              present source, with: Api::V1::Entities::ProviderSourceEntity
            else
              error!({ errors: source.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_sources/:id
          desc "Delete a provider source record"
          delete do
            source = ProviderSource.find(params[:id])
            if source.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider source record"] }, 500)
            end
          end

        end
      end
    end
  end
end
