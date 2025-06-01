module Api
  module V1
    class DisclosureCategories < Grape::API

      helpers do
        params :shared_category_params do
          optional :title, type: String, desc: 'Title of the category.'
          optional :note, type: String, desc: 'Note associated with the category.'
          optional :alert_type, type: String, desc: 'Type of alert associated with the category.'
        end
      end

      resource :disclosure_categories do

        # GET /api/v1/disclosure_categories
        desc "Return a list of disclosure categories"
        get do
          categories = DisclosureCategory.all
          present categories, with: Api::V1::Entities::DisclosureCategoryEntity
        end

        # POST /api/v1/disclosure_categories
        desc "Create a disclosure category"
        params do
          use :shared_category_params
          requires :title
        end
        post do
          category_params = declared(params, include_missing: false)
          category = DisclosureCategory.new(category_params)

          if category.save
            present category, with: Api::V1::Entities::DisclosureCategoryEntity
          else
            error!({ errors: category.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/disclosure_categories/:id
          desc "Return a specific disclosure category"
          get do
            category = DisclosureCategory.find(params[:id])
            present category, with: Api::V1::Entities::DisclosureCategoryEntity
          end

          # PUT /api/v1/disclosure_categories/:id
          desc "Update a disclosure category"
          params do
            use :shared_category_params
          end
          put do
            category = DisclosureCategory.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if category.update(update_params)
              present category, with: Api::V1::Entities::DisclosureCategoryEntity
            else
              error!({ errors: category.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/disclosure_categories/:id
          desc "Delete a disclosure category"
          delete do
            category = DisclosureCategory.find(params[:id])
            if category.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete disclosure category"] }, 500)
            end
          end

        end
      end
    end
  end
end
