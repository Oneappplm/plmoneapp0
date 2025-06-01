module Api
  module V1
    class ProviderSourceCmes < Grape::API

      helpers do
        params :shared_cme_params do
          optional :training, type: String, desc: 'Name or description of the training.'
          optional :month_attended, type: String, desc: 'Month the training was attended.'
          optional :year_attended, type: String, desc: 'Year the training was attended.'
          optional :hours, type: String, desc: 'Number of hours for the CME.'
        end
      end

      resource :provider_source_cmes do

        # GET /api/v1/provider_source_cmes
        desc "Return a list of provider source CME records"
        params do
          optional :provider_source_id, type: Integer, desc: "Filter by ProviderSource ID."
        end
        get do
          cmes = ProviderSourceCme.all
          cmes = cmes.where(provider_source_id: params[:provider_source_id]) if params[:provider_source_id].present?
          present cmes, with: Api::V1::Entities::ProviderSourceCmeEntity
        end

        # POST /api/v1/provider_source_cmes
        desc "Create a provider source CME record"
        params do
          use :shared_cme_params
          requires :provider_source_id, type: Integer, desc: 'ID of the associated ProviderSource.'
        end
        post do
          cme_params = declared(params, include_missing: false)
          cme = ProviderSourceCme.new(cme_params)

          if cme.save
            present cme, with: Api::V1::Entities::ProviderSourceCmeEntity
          else
            error!({ errors: cme.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_source_cmes/:id
          desc "Return a specific provider source CME record"
          get do
            cme = ProviderSourceCme.find(params[:id])
            present cme, with: Api::V1::Entities::ProviderSourceCmeEntity
          end

          # PUT /api/v1/provider_source_cmes/:id
          desc "Update a provider source CME record"
          params do
            use :shared_cme_params
          end
          put do
            cme = ProviderSourceCme.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if cme.update(update_params)
              present cme, with: Api::V1::Entities::ProviderSourceCmeEntity
            else
              error!({ errors: cme.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_source_cmes/:id
          desc "Delete a provider source CME record"
          delete do
            cme = ProviderSourceCme.find(params[:id])
            if cme.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider source CME record"] }, 500)
            end
          end

        end
      end
    end
  end
end
