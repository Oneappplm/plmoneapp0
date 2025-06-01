module Api
  module V1
    class Roles < Grape::API

      helpers do
        params :shared_role_params do
          optional :name, type: String, desc: "Name for the role."
          optional :slug, type: String, desc: "Unique slug for the role."
        end
      end

      resource :roles do

        # GET /api/v1/roles
        desc "Return a list of roles"
        get do
          roles = Role.all
          present roles, with: Api::V1::Entities::RoleEntity
        end

        # POST /api/v1/roles
        desc "Create a role"
        params do
          use :shared_role_params
          requires :name
          optional :slug
        end
        post do
          role_params = declared(params, include_missing: false)
          role = Role.new(role_params)

          if role.save
            present role, with: Api::V1::Entities::RoleEntity
          else
            error!({ errors: role.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/roles/:id
          desc "Return a specific role"
          get do
            role = Role.find(params[:id])
            present role, with: Api::V1::Entities::RoleEntity
          end

          # PUT /api/v1/roles/:id
          desc "Update a specific role"
          params do
            use :shared_role_params
          end
          put do
            role = Role.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if role.update(update_params)
              present role, with: Api::V1::Entities::RoleEntity
            else
              error!({ errors: role.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/roles/:id
          desc "Delete a specific role"
          delete do
            role = Role.find(params[:id])
            if role.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete role"] }, 500)
            end
          end

        end
      end
    end
  end
end
