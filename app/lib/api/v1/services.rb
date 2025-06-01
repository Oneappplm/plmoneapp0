module Api
  module V1
    class Services < Grape::API

      helpers do
        params :shared_service_params do
          requires :name, type: String, desc: 'Name of the service'
          optional :description, type: String, desc: 'Description of the service'
        end
      end

      resource :services do

        # GET /api/v1/services
        desc 'Return all services'
        get do
          services = Service.all
          present services, with: Api::V1::Entities::ServiceEntity
        end

        # POST /api/v1/services
        desc 'Create a service'
        params do
          use :shared_service_params
        end
        post do
          service = Service.new(declared(params, include_missing: false))

          if service.save
            present service, with: Api::V1::Entities::ServiceEntity
          else
            error!({ errors: service.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/services/:id
          desc 'Return a specific service'
          get do
            service = Service.find(params[:id])
            present service, with: Api::V1::Entities::ServiceEntity
          end

          # PUT /api/v1/services/:id
          desc 'Update a service'
          params do
            use :shared_service_params
          end
          put do
            service = Service.find(params[:id])
            update_params = declared(params, include_missing: false)

            if service.update(update_params)
              present service, with: Api::V1::Entities::ServiceEntity
            else
              error!({ errors: service.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/services/:id
          desc 'Delete a service'
          delete do
            service = Service.find(params[:id])
            if service.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete service'] }, 500)
            end
          end

        end
      end
    end
  end
end
