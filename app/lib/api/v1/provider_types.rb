module Api
  module V1
    class ProviderTypes < Grape::API

      helpers do
        params :shared_provider_type_params do
          requires :name, type: String, desc: 'Name of the provider type'
          optional :description, type: String, desc: 'Description of the provider type'
        end
      end

      resource :provider_types do

        # GET /api/v1/provider_types
        desc 'Return all provider types'
        get do
          types = ProviderType.all
          present types, with: Api::V1::Entities::ProviderTypeEntity
        end

        # POST /api/v1/provider_types
        desc 'Create a provider type'
        params do
          use :shared_provider_type_params
        end
        post do
          type = ProviderType.new(declared(params, include_missing: false))

          if type.save
            present type, with: Api::V1::Entities::ProviderTypeEntity
          else
            error!({ errors: type.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_types/:id
          desc 'Return a specific provider type'
          get do
            type = ProviderType.find(params[:id])
            present type, with: Api::V1::Entities::ProviderTypeEntity
          end

          # PUT /api/v1/provider_types/:id
          desc 'Update a provider type'
          params do
            use :shared_provider_type_params
          end
          put do
            type = ProviderType.find(params[:id])
            update_params = declared(params, include_missing: false)

            if type.update(update_params)
              present type, with: Api::V1::Entities::ProviderTypeEntity
            else
              error!({ errors: type.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_types/:id
          desc 'Delete a provider type'
          delete do
            type = ProviderType.find(params[:id])
            if type.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete provider type'] }, 500)
            end
          end

        end
      end
    end
  end
end
