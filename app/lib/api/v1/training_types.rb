module Api
  module V1
    class TrainingTypes < Grape::API

      helpers do
        params :shared_training_type_params do
          requires :name, type: String, desc: 'Name of the training type'
          optional :description, type: String, desc: 'Description of the training type'
        end
      end

      resource :training_types do

        # GET /api/v1/training_types
        desc 'Return all training types'
        get do
          types = TrainingType.all
          present types, with: Api::V1::Entities::TrainingTypeEntity
        end

        # POST /api/v1/training_types
        desc 'Create a training type'
        params do
          use :shared_training_type_params
        end
        post do
          type = TrainingType.new(declared(params, include_missing: false))

          if type.save
            present type, with: Api::V1::Entities::TrainingTypeEntity
          else
            error!({ errors: type.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/training_types/:id
          desc 'Return a specific training type'
          get do
            type = TrainingType.find(params[:id])
            present type, with: Api::V1::Entities::TrainingTypeEntity
          end

          # PUT /api/v1/training_types/:id
          desc 'Update a training type'
          params do
            use :shared_training_type_params
          end
          put do
            type = TrainingType.find(params[:id])
            update_params = declared(params, include_missing: false)

            if type.update(update_params)
              present type, with: Api::V1::Entities::TrainingTypeEntity
            else
              error!({ errors: type.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/training_types/:id
          desc 'Delete a training type'
          delete do
            type = TrainingType.find(params[:id])
            if type.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete training type'] }, 500)
            end
          end

        end
      end
    end
  end
end
