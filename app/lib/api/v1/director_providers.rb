module Api
  module V1
    class DirectorProviders < Grape::API
      resource :director_providers do

        # GET /api/v1/director_providers
        desc "Return a list of director-provider associations"
        params do
          optional :user_id, type: Integer, desc: "Filter by User ID (Director)."
          optional :virtual_review_committee_id, type: Integer, desc: "Filter by Virtual Review Committee ID."
        end
        get do
          associations = DirectorProvider.all
          associations = associations.where(user_id: params[:user_id]) if params[:user_id].present?
          associations = associations.where(virtual_review_committee_id: params[:virtual_review_committee_id]) if params[:virtual_review_committee_id].present?
          present associations, with: Api::V1::Entities::DirectorProviderEntity
        end

        # POST /api/v1/director_providers
        desc "Create a director-provider association"
        params do
          requires :user_id, type: Integer, desc: "ID of the User (Director)."
          requires :virtual_review_committee_id, type: Integer, desc: "ID of the Virtual Review Committee."
        end
        post do
          assoc_params = declared(params, include_missing: false)
          association = DirectorProvider.new(assoc_params)

          if association.save
            present association, with: Api::V1::Entities::DirectorProviderEntity
          else
            error!({ errors: association.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/director_providers/:id
          desc "Return a specific director-provider association"
          get do
            association = DirectorProvider.find(params[:id])
            present association, with: Api::V1::Entities::DirectorProviderEntity
          end

          # DELETE /api/v1/director_providers/:id
          desc "Delete a specific director-provider association"
          delete do
            association = DirectorProvider.find(params[:id])
            if association.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete director-provider association"] }, 500)
            end
          end

        end
      end
    end
  end
end
