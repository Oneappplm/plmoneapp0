module Api
  module V1
    class RoleBasedAccesses < Grape::API

      helpers do
        params :shared_access_params do
          optional :role, type: String, desc: "The role string this rule applies to."
          optional :page, type: String, desc: "The page or resource this rule applies to."
          optional :can_create, type: Boolean, desc: "Permission to create."
          optional :can_read, type: Boolean, desc: "Permission to read/view."
          optional :can_update, type: Boolean, desc: "Permission to update."
          optional :can_delete, type: Boolean, desc: "Permission to delete."
        end
      end

      resource :role_based_accesses do

        # GET /api/v1/role_based_accesses
        desc "Return a list of role-based access rules"
        params do
          optional :role, type: String, desc: "Filter rules by role string."
          optional :page, type: String, desc: "Filter rules by page/resource string."
        end
        get do
          access_rules = RoleBasedAccess.all
          access_rules = access_rules.where(role: params[:role]) if params[:role].present?
          access_rules = access_rules.where(page: params[:page]) if params[:page].present?
          present access_rules, with: Api::V1::Entities::RoleBasedAccessEntity
        end

        # POST /api/v1/role_based_accesses
        desc "Create a role-based access rule"
        params do
          use :shared_access_params
          requires :role
          requires :page
          optional :can_create, default: false
          optional :can_read, default: false
          optional :can_update, default: false
          optional :can_delete, default: false
        end
        post do
          access_params = declared(params, include_missing: true)
          access_rule = RoleBasedAccess.new(access_params)

          if access_rule.save
            present access_rule, with: Api::V1::Entities::RoleBasedAccessEntity
          else
            error!({ errors: access_rule.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/role_based_accesses/:id
          desc "Return a specific access rule"
          get do
            access_rule = RoleBasedAccess.find(params[:id])
            present access_rule, with: Api::V1::Entities::RoleBasedAccessEntity
          end

          # PUT /api/v1/role_based_accesses/:id
          desc "Update a specific access rule"
          params do
            use :shared_access_params
          end
          put do
            access_rule = RoleBasedAccess.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if access_rule.update(update_params)
              present access_rule, with: Api::V1::Entities::RoleBasedAccessEntity
            else
              error!({ errors: access_rule.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/role_based_accesses/:id
          desc "Delete a specific access rule"
          delete do
            access_rule = RoleBasedAccess.find(params[:id])
            if access_rule.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete access rule"] }, 500)
            end
          end

        end
      end
    end
  end
end
