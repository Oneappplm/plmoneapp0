module Api
  module V1
    class Specialties < Grape::API

      helpers do
        params :shared_specialty_params do
          requires :name, type: String, desc: 'Name of the specialty'
          optional :description, type: String, desc: 'Description of the specialty'
        end
      end

      resource :specialties do

        # GET /api/v1/specialties
        desc 'Return all specialties'
        get do
          specialties = Specialty.all
          present specialties, with: Api::V1::Entities::SpecialtyEntity
        end

        # POST /api/v1/specialties
        desc 'Create a specialty'
        params do
          use :shared_specialty_params
        end
        post do
          specialty = Specialty.new(declared(params, include_missing: false))

          if specialty.save
            present specialty, with: Api::V1::Entities::SpecialtyEntity
          else
            error!({ errors: specialty.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/specialties/:id
          desc 'Return a specific specialty'
          get do
            specialty = Specialty.find(params[:id])
            present specialty, with: Api::V1::Entities::SpecialtyEntity
          end

          # PUT /api/v1/specialties/:id
          desc 'Update a specialty'
          params do
            use :shared_specialty_params
          end
          put do
            specialty = Specialty.find(params[:id])
            update_params = declared(params, include_missing: false)

            if specialty.update(update_params)
              present specialty, with: Api::V1::Entities::SpecialtyEntity
            else
              error!({ errors: specialty.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/specialties/:id
          desc 'Delete a specialty'
          delete do
            specialty = Specialty.find(params[:id])
            if specialty.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete specialty'] }, 500)
            end
          end

        end
      end
    end
  end
end
