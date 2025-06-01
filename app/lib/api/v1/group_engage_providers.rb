module Api
  module V1
    class GroupEngageProviders < Grape::API

      helpers do
        params :shared_engage_provider_params do
          optional :practice_location_id, type: Integer, desc: 'ID of the associated PracticeLocation.'
          optional :user_id, type: Integer, desc: 'ID of the associated User.'
          optional :first_name, type: String, desc: 'First name.'
          optional :middle_name, type: String, desc: 'Middle name.'
          optional :last_name, type: String, desc: 'Last name.'
          optional :date_of_birth, type: DateTime, desc: 'Date of birth.'
          optional :email_address, type: String, desc: 'Email address.'
          optional :ssn, type: String, desc: 'Social Security Number (Sensitive).'
        end
      end

      resource :group_engage_providers do

        # GET /api/v1/group_engage_providers
        desc "Return a list of group engage provider records"
        params do
          optional :practice_location_id, type: Integer, desc: "Filter by PracticeLocation ID."
          optional :user_id, type: Integer, desc: "Filter by User ID."
          optional :email_address, type: String, desc: "Filter by email address."
        end
        get do
          providers = GroupEngageProvider.all
          providers = providers.where(practice_location_id: params[:practice_location_id]) if params[:practice_location_id].present?
          providers = providers.where(user_id: params[:user_id]) if params[:user_id].present?
          providers = providers.where(email_address: params[:email_address]) if params[:email_address].present?
          present providers, with: Api::V1::Entities::GroupEngageProviderEntity
        end

        # POST /api/v1/group_engage_providers
        desc "Create a group engage provider record"
        params do
          use :shared_engage_provider_params
          requires :first_name
          requires :last_name
          requires :email_address
        end
        post do
          provider_params = declared(params, include_missing: false)
          provider = GroupEngageProvider.new(provider_params)

          if provider.save
            present provider, with: Api::V1::Entities::GroupEngageProviderEntity
          else
            error!({ errors: provider.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/group_engage_providers/:id
          desc "Return a specific group engage provider record"
          get do
            provider = GroupEngageProvider.find(params[:id])
            present provider, with: Api::V1::Entities::GroupEngageProviderEntity
          end

          # PUT /api/v1/group_engage_providers/:id
          desc "Update a group engage provider record"
          params do
            use :shared_engage_provider_params
          end
          put do
            provider = GroupEngageProvider.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if provider.update(update_params)
              present provider, with: Api::V1::Entities::GroupEngageProviderEntity
            else
              error!({ errors: provider.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/group_engage_providers/:id
          desc "Delete a group engage provider record"
          delete do
            provider = GroupEngageProvider.find(params[:id])
            if provider.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete group engage provider record"] }, 500)
            end
          end

        end
      end
    end
  end
end
