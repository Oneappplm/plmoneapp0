module Api
  module V1
    class GroupRoles < Grape::API

      helpers do
        params :shared_group_role_params do
          requires :name, type: String, desc: 'Name of the group role'
        end
      end

      resource :group_roles do

        # GET /api/v1/group_roles
        desc 'Return all group roles'
        get do
          group_roles = GroupRole.all
          present group_roles, with: Api::V1::Entities::GroupRoleEntity
        end

        # POST /api/v1/group_roles
        desc 'Create a group role'
        params do
          use :shared_group_role_params
        end
        post do
          group_role = GroupRole.new(declared(params, include_missing: false))

          if group_role.save
            present group_role, with: Api::V1::Entities::GroupRoleEntity
          else
            error!({ errors: group_role.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/group_roles/:id
          desc 'Return a specific group role'
          get do
            group_role = GroupRole.find(params[:id])
            present group_role, with: Api::V1::Entities::GroupRoleEntity
          end

          # PUT /api/v1/group_roles/:id
          desc 'Update a group role'
          params do
            use :shared_group_role_params
          end
          put do
            group_role = GroupRole.find(params[:id])
            update_params = declared(params, include_missing: false)

            if group_role.update(update_params)
              present group_role, with: Api::V1::Entities::GroupRoleEntity
            else
              error!({ errors: group_role.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/group_roles/:id
          desc 'Delete a group role'
          delete do
            group_role = GroupRole.find(params[:id])
            if group_role.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete group role'] }, 500)
            end
          end

        end
      end
    end
  end
end
