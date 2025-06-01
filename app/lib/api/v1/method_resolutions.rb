module Api
  module V1
    class MethodResolutions < Grape::API

      helpers do
        params :shared_method_resolution_params do
          requires :name, type: String, desc: 'Name of the method resolution'
          optional :description, type: String, desc: 'Description of the method resolution'
        end
      end

      resource :method_resolutions do

        # GET /api/v1/method_resolutions
        desc 'Return all method resolutions'
        get do
          resolutions = MethodResolution.all
          present resolutions, with: Api::V1::Entities::MethodResolutionEntity
        end

        # POST /api/v1/method_resolutions
        desc 'Create a method resolution'
        params do
          use :shared_method_resolution_params
        end
        post do
          resolution = MethodResolution.new(declared(params, include_missing: false))

          if resolution.save
            present resolution, with: Api::V1::Entities::MethodResolutionEntity
          else
            error!({ errors: resolution.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/method_resolutions/:id
          desc 'Return a specific method resolution'
          get do
            resolution = MethodResolution.find(params[:id])
            present resolution, with: Api::V1::Entities::MethodResolutionEntity
          end

          # PUT /api/v1/method_resolutions/:id
          desc 'Update a method resolution'
          params do
            use :shared_method_resolution_params
          end
          put do
            resolution = MethodResolution.find(params[:id])
            update_params = declared(params, include_missing: false)

            if resolution.update(update_params)
              present resolution, with: Api::V1::Entities::MethodResolutionEntity
            else
              error!({ errors: resolution.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/method_resolutions/:id
          desc 'Delete a method resolution'
          delete do
            resolution = MethodResolution.find(params[:id])
            if resolution.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete method resolution'] }, 500)
            end
          end

        end
      end
    end
  end
end
