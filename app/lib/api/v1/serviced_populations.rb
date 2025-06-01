module Api
  module V1
    class ServicedPopulations < Grape::API

      helpers do
        params :shared_serviced_population_params do
          requires :name, type: String, desc: 'Name of the serviced population'
          optional :description, type: String, desc: 'Description of the serviced population'
        end
      end

      resource :serviced_populations do

        # GET /api/v1/serviced_populations
        desc 'Return all serviced populations'
        get do
          populations = ServicedPopulation.all
          present populations, with: Api::V1::Entities::ServicedPopulationEntity
        end

        # POST /api/v1/serviced_populations
        desc 'Create a serviced population'
        params do
          use :shared_serviced_population_params
        end
        post do
          population = ServicedPopulation.new(declared(params, include_missing: false))

          if population.save
            present population, with: Api::V1::Entities::ServicedPopulationEntity
          else
            error!({ errors: population.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/serviced_populations/:id
          desc 'Return a specific serviced population'
          get do
            population = ServicedPopulation.find(params[:id])
            present population, with: Api::V1::Entities::ServicedPopulationEntity
          end

          # PUT /api/v1/serviced_populations/:id
          desc 'Update a serviced population'
          params do
            use :shared_serviced_population_params
          end
          put do
            population = ServicedPopulation.find(params[:id])
            update_params = declared(params, include_missing: false)

            if population.update(update_params)
              present population, with: Api::V1::Entities::ServicedPopulationEntity
            else
              error!({ errors: population.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/serviced_populations/:id
          desc 'Delete a serviced population'
          delete do
            population = ServicedPopulation.find(params[:id])
            if population.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete serviced population'] }, 500)
            end
          end

        end
      end
    end
  end
end
