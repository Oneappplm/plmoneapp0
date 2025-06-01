module Api
  module V1
    class PrivilegeStatuses < Grape::API

      helpers do
        params :shared_privilege_status_params do
          requires :name, type: String, desc: 'Name of the privilege status'
          optional :description, type: String, desc: 'Description of the privilege status'
        end
      end

      resource :privilege_statuses do

        # GET /api/v1/privilege_statuses
        desc 'Return all privilege statuses'
        get do
          statuses = PrivilegeStatus.all
          present statuses, with: Api::V1::Entities::PrivilegeStatusEntity
        end

        # POST /api/v1/privilege_statuses
        desc 'Create a privilege status'
        params do
          use :shared_privilege_status_params
        end
        post do
          status = PrivilegeStatus.new(declared(params, include_missing: false))

          if status.save
            present status, with: Api::V1::Entities::PrivilegeStatusEntity
          else
            error!({ errors: status.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/privilege_statuses/:id
          desc 'Return a specific privilege status'
          get do
            status = PrivilegeStatus.find(params[:id])
            present status, with: Api::V1::Entities::PrivilegeStatusEntity
          end

          # PUT /api/v1/privilege_statuses/:id
          desc 'Update a privilege status'
          params do
            use :shared_privilege_status_params
          end
          put do
            status = PrivilegeStatus.find(params[:id])
            update_params = declared(params, include_missing: false)

            if status.update(update_params)
              present status, with: Api::V1::Entities::PrivilegeStatusEntity
            else
              error!({ errors: status.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/privilege_statuses/:id
          desc 'Delete a privilege status'
          delete do
            status = PrivilegeStatus.find(params[:id])
            if status.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete privilege status'] }, 500)
            end
          end

        end
      end
    end
  end
end
