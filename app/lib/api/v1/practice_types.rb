module Api
  module V1
    class PracticeTypes < Grape::API

      helpers do
        params :shared_practice_type_params do
          requires :name, type: String, desc: 'Name of the practice type'
          optional :description, type: String, desc: 'Description of the practice type'
        end
      end

      resource :practice_types do

        # GET /api/v1/practice_types
        desc 'Return all practice types'
        get do
          types = PracticeType.all
          present types, with: Api::V1::Entities::PracticeTypeEntity
        end

        # POST /api/v1/practice_types
        desc 'Create a practice type'
        params do
          use :shared_practice_type_params
        end
        post do
          type = PracticeType.new(declared(params, include_missing: false))

          if type.save
            present type, with: Api::V1::Entities::PracticeTypeEntity
          else
            error!({ errors: type.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/practice_types/:id
          desc 'Return a specific practice type'
          get do
            type = PracticeType.find(params[:id])
            present type, with: Api::V1::Entities::PracticeTypeEntity
          end

          # PUT /api/v1/practice_types/:id
          desc 'Update a practice type'
          params do
            use :shared_practice_type_params
          end
          put do
            type = PracticeType.find(params[:id])
            update_params = declared(params, include_missing: false)

            if type.update(update_params)
              present type, with: Api::V1::Entities::PracticeTypeEntity
            else
              error!({ errors: type.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/practice_types/:id
          desc 'Delete a practice type'
          delete do
            type = PracticeType.find(params[:id])
            if type.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete practice type'] }, 500)
            end
          end

        end
      end
    end
  end
end
