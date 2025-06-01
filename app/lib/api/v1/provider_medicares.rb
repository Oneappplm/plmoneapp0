module Api
  module V1
    class ProviderMedicares < Grape::API

      helpers do
        params :shared_medicare_params do
          optional :ptan_number, type: String, desc: 'Medicare PTAN number.'
          optional :effective_date, type: DateTime, desc: 'Medicare effective date.'
          optional :medicare_username, type: String, desc: 'Medicare username.'
          optional :question, type: String, desc: 'Medicare security question.'
          optional :answer, type: String, desc: 'Medicare security answer.'
          optional :reval_date, type: DateTime, desc: 'Medicare revalidation date.'
          optional :notes, type: String, desc: 'Notes related to Medicare enrollment.'
          optional :password, type: String, desc: 'Password for Medicare account.'
        end
      end

      resource :provider_medicares do

        # GET /api/v1/provider_medicares
        desc "Return a list of provider Medicare records"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
        end
        get do
          medicares = ProviderMedicare.all
          medicares = medicares.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          present medicares, with: Api::V1::Entities::ProviderMedicareEntity
        end

        # POST /api/v1/provider_medicares
        desc "Create a provider Medicare record"
        params do
          use :shared_medicare_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
          requires :password
        end
        post do
          medicare_params = declared(params, include_missing: false)
          medicare = ProviderMedicare.new(medicare_params)

          if medicare.save
            present medicare, with: Api::V1::Entities::ProviderMedicareEntity
          else
            error!({ errors: medicare.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_medicares/:id
          desc "Return a specific provider Medicare record"
          get do
            medicare = ProviderMedicare.find(params[:id])
            present medicare, with: Api::V1::Entities::ProviderMedicareEntity
          end

          # PUT /api/v1/provider_medicares/:id
          desc "Update a provider Medicare record"
          params do
            use :shared_medicare_params
          end
          put do
            medicare = ProviderMedicare.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)
            update_params.delete(:password) if update_params[:password].blank?

            if medicare.update(update_params)
              present medicare, with: Api::V1::Entities::ProviderMedicareEntity
            else
              error!({ errors: medicare.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_medicares/:id
          desc "Delete a provider Medicare record"
          delete do
            medicare = ProviderMedicare.find(params[:id])
            if medicare.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider Medicare record"] }, 500)
            end
          end

        end
      end
    end
  end
end
