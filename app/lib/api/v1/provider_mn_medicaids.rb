module Api
  module V1
    class ProviderMnMedicaids < Grape::API

      helpers do
        params :shared_mn_medicaid_params do
          optional :mn_medicaid_number, type: String, desc: 'MN Medicaid number.'
          optional :mn_medicaid_username, type: String, desc: 'MN Medicaid username.'
          optional :question, type: String, desc: 'MN Medicaid security question.'
          optional :answer, type: String, desc: 'MN Medicaid security answer.'
          optional :password, type: String, desc: 'Password for MN Medicaid account.'
        end
      end

      resource :provider_mn_medicaids do

        # GET /api/v1/provider_mn_medicaids
        desc "Return a list of provider MN Medicaid records"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
        end
        get do
          medicaids = ProviderMnMedicaid.all
          medicaids = medicaids.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          present medicaids, with: Api::V1::Entities::ProviderMnMedicaidEntity
        end

        # POST /api/v1/provider_mn_medicaids
        desc "Create a provider MN Medicaid record"
        params do
          use :shared_mn_medicaid_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
          requires :password
        end
        post do
          medicaid_params = declared(params, include_missing: false)
          medicaid = ProviderMnMedicaid.new(medicaid_params)

          if medicaid.save
            present medicaid, with: Api::V1::Entities::ProviderMnMedicaidEntity
          else
            error!({ errors: medicaid.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_mn_medicaids/:id
          desc "Return a specific provider MN Medicaid record"
          get do
            medicaid = ProviderMnMedicaid.find(params[:id])
            present medicaid, with: Api::V1::Entities::ProviderMnMedicaidEntity
          end

          # PUT /api/v1/provider_mn_medicaids/:id
          desc "Update a provider MN Medicaid record"
          params do
            use :shared_mn_medicaid_params
          end
          put do
            medicaid = ProviderMnMedicaid.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)
            update_params.delete(:password) if update_params[:password].blank?

            if medicaid.update(update_params)
              present medicaid, with: Api::V1::Entities::ProviderMnMedicaidEntity
            else
              error!({ errors: medicaid.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_mn_medicaids/:id
          desc "Delete a provider MN Medicaid record"
          delete do
            medicaid = ProviderMnMedicaid.find(params[:id])
            if medicaid.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider MN Medicaid record"] }, 500)
            end
          end

        end
      end
    end
  end
end
