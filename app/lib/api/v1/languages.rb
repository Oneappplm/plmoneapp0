module Api
  module V1
    class Languages < Grape::API

      helpers do
        params :shared_language_params do
          requires :name, type: String, desc: 'Name of the language'
          optional :code, type: String, desc: 'Language code'
        end
      end

      resource :languages do

        # GET /api/v1/languages
        desc 'Return all languages'
        get do
          languages = Language.all
          present languages, with: Api::V1::Entities::LanguageEntity
        end

        # POST /api/v1/languages
        desc 'Create a language'
        params do
          use :shared_language_params
        end
        post do
          language = Language.new(declared(params, include_missing: false))

          if language.save
            present language, with: Api::V1::Entities::LanguageEntity
          else
            error!({ errors: language.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/languages/:id
          desc 'Return a specific language'
          get do
            language = Language.find(params[:id])
            present language, with: Api::V1::Entities::LanguageEntity
          end

          # PUT /api/v1/languages/:id
          desc 'Update a language'
          params do
            use :shared_language_params
          end
          put do
            language = Language.find(params[:id])
            update_params = declared(params, include_missing: false)

            if language.update(update_params)
              present language, with: Api::V1::Entities::LanguageEntity
            else
              error!({ errors: language.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/languages/:id
          desc 'Delete a language'
          delete do
            language = Language.find(params[:id])
            if language.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete language'] }, 500)
            end
          end

        end
      end
    end
  end
end
