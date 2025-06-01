module Api
  module V1
    class ProviderWiMedicaids < Grape::API

      helpers do
        params :shared_wi_medicaid_params do
          optional :wi_medicaid, type: String, desc: 'WI Medicaid number/identifier.'
          optional :wi_medicaid_username, type: String, desc: 'WI Medicaid username.'
          optional :question, type: String, desc: 'WI Medicaid security question.'
          optional :answer, type: String, desc: 'WI Medicaid security answer.'
          optional :notes, type: String, desc: 'Notes related to WI Medicaid enrollment.'
          optional :password, type: String, desc: 'Password for WI Medicaid account.'
        end
      end

      resource :provider_wi_medicaids do

        # GET /api/v1/provider_wi_medicaids
        desc "Return a list of provider WI Medicaid records"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
        end
        get do
          medicaids = ProviderWiMedicaid.all
          medicaids = medicaids.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          present medicaids, with: Api::V1::Entities::ProviderWiMedicaidEntity
        end

        # POST /api/v1/provider_wi_medicaids
        desc "Create a provider WI Medicaid record"
        params do
          use :shared_wi_medicaid_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
        end
        post do
          medicaid_params = declared(params, include_missing: false)
          medicaid = ProviderWiMedicaid.new(medicaid_params)

          if medicaid.save
            present medicaid, with: Api::V1::Entities::ProviderWiMedicaidEntity
          else
            error!({ errors: medicaid.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_wi_medicaids/:id
          desc "Return a specific provider WI Medicaid record"
          get do
            medicaid = ProviderWiMedicaid.find(params[:id])
            present medicaid, with: Api::V1::Entities::ProviderWiMedicaidEntity
          end

          # PUT /api/v1/provider_wi_medicaids/:id
          desc "Update a provider WI Medicaid record"
          params do
            use :shared_wi_medicaid_params
          end
          put do
            medicaid = ProviderWiMedicaid.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)
            update_params.delete(:password) if update_params[:password].blank?

            if medicaid.update(update_params)
              present medicaid, with: Api::V1::Entities::ProviderWiMedicaidEntity
            else
              error!({ errors: medicaid.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_wi_medicaids/:id
          desc "Delete a provider WI Medicaid record"
          delete do
            medicaid = ProviderWiMedicaid.find(params[:id])
            if medicaid.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider WI Medicaid record"] }, 500)
            end
          end

        end
      end
    end
  end
end
