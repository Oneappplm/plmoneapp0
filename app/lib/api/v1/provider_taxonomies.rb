# app/lib/api/v1/provider_taxonomies.rb

module Api
  module V1
    class ProviderTaxonomies < Grape::API

      helpers do
        params :shared_taxonomy_params do
          optional :taxonomy_code, type: String, desc: 'Taxonomy code.'
          optional :specialty, type: String, desc: 'Associated specialty.'
        end
      end

      resource :provider_taxonomies do

        # GET /api/v1/provider_taxonomies
        desc "Return a list of provider taxonomies"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
          optional :taxonomy_code, type: String, desc: "Filter by taxonomy code."
        end
        get do
          taxonomies = ProviderTaxonomy.all
          taxonomies = taxonomies.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          taxonomies = taxonomies.where(taxonomy_code: params[:taxonomy_code]) if params[:taxonomy_code].present?
          present taxonomies, with: Api::V1::Entities::ProviderTaxonomyEntity
        end

        # POST /api/v1/provider_taxonomies
        desc "Create a provider taxonomy record"
        params do
          use :shared_taxonomy_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
        end
        post do
          taxonomy_params = declared(params, include_missing: false)
          taxonomy = ProviderTaxonomy.new(taxonomy_params)

          if taxonomy.save
            present taxonomy, with: Api::V1::Entities::ProviderTaxonomyEntity
          else
            error!({ errors: taxonomy.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_taxonomies/:id
          desc "Return a specific provider taxonomy record"
          get do
            taxonomy = ProviderTaxonomy.find(params[:id])
            present taxonomy, with: Api::V1::Entities::ProviderTaxonomyEntity
          end

          # PUT /api/v1/provider_taxonomies/:id
          desc "Update a provider taxonomy record"
          params do
            use :shared_taxonomy_params
            optional :provider_id, type: Integer, desc: 'ID of the associated Provider.' # If re-assigning allowed
          end
          put do
            taxonomy = ProviderTaxonomy.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if taxonomy.update(update_params)
              present taxonomy, with: Api::V1::Entities::ProviderTaxonomyEntity
            else
              error!({ errors: taxonomy.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_taxonomies/:id
          desc "Delete a provider taxonomy record"
          delete do
            taxonomy = ProviderTaxonomy.find(params[:id])
            if taxonomy.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider taxonomy record"] }, 500)
            end
          end

        end
      end
    end
  end
end
