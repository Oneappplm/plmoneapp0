module Api
  module V1
    class EducationTypes < Grape::API

      helpers do
        params :shared_education_type_params do
          requires :name, type: String, desc: 'Name of the education type'
        end
      end

      resource :education_types do

        # GET /api/v1/education_types
        desc 'Return all education types'
        get do
          education_types = EducationType.all
          present education_types, with: Api::V1::Entities::EducationTypeEntity
        end

        # POST /api/v1/education_types
        desc 'Create an education type'
        params do
          use :shared_education_type_params
        end
        post do
          education_type = EducationType.new(declared(params, include_missing: false))

          if education_type.save
            present education_type, with: Api::V1::Entities::EducationTypeEntity
          else
            error!({ errors: education_type.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/education_types/:id
          desc 'Return a specific education type'
          get do
            education_type = EducationType.find(params[:id])
            present education_type, with: Api::V1::Entities::EducationTypeEntity
          end

          # PUT /api/v1/education_types/:id
          desc 'Update an education type'
          params do
            use :shared_education_type_params
          end
          put do
            education_type = EducationType.find(params[:id])
            update_params = declared(params, include_missing: false)

            if education_type.update(update_params)
              present education_type, with: Api::V1::Entities::EducationTypeEntity
            else
              error!({ errors: education_type.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/education_types/:id
          desc 'Delete an education type'
          delete do
            education_type = EducationType.find(params[:id])
            if education_type.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete education type'] }, 500)
            end
          end

        end
      end
    end
  end
end
