module Api
  module V1
    class VisaTypes < Grape::API

      helpers do
        params :shared_visa_type_params do
          requires :name, type: String, desc: 'Name of the visa type'
          optional :description, type: String, desc: 'Description of the visa type'
        end
      end

      resource :visa_types do

        # GET /api/v1/visa_types
        desc 'Return all visa types'
        get do
          visa_types = VisaType.all
          present visa_types, with: Api::V1::Entities::VisaTypeEntity
        end

        # POST /api/v1/visa_types
        desc 'Create a visa type'
        params do
          use :shared_visa_type_params
        end
        post do
          visa_type = VisaType.new(declared(params, include_missing: false))

          if visa_type.save
            present visa_type, with: Api::V1::Entities::VisaTypeEntity
          else
            error!({ errors: visa_type.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/visa_types/:id
          desc 'Return a specific visa type'
          get do
            visa_type = VisaType.find(params[:id])
            present visa_type, with: Api::V1::Entities::VisaTypeEntity
          end

          # PUT /api/v1/visa_types/:id
          desc 'Update a visa type'
          params do
            use :shared_visa_type_params
          end
          put do
            visa_type = VisaType.find(params[:id])
            update_params = declared(params, include_missing: false)

            if visa_type.update(update_params)
              present visa_type, with: Api::V1::Entities::VisaTypeEntity
            else
              error!({ errors: visa_type.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/visa_types/:id
          desc 'Delete a visa type'
          delete do
            visa_type = VisaType.find(params[:id])
            if visa_type.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete visa type'] }, 500)
            end
          end

        end
      end
    end
  end
end
