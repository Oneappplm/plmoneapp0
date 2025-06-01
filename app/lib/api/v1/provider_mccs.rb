module Api
  module V1
    class ProviderMccs < Grape::API

      helpers do
        params :shared_mcc_params do
          optional :mcc_username, type: String, desc: 'MCC username.'
          optional :mcc_electronic_signature_code, type: String, desc: 'MCC electronic signature code.'
          optional :password, type: String, desc: 'Password for MCC account.'
        end
      end

      resource :provider_mccs do

        # GET /api/v1/provider_mccs
        desc "Return a list of provider MCC records"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
        end
        get do
          mccs = ProviderMcc.all
          mccs = mccs.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          present mccs, with: Api::V1::Entities::ProviderMccEntity
        end

        # POST /api/v1/provider_mccs
        desc "Create a provider MCC record"
        params do
          use :shared_mcc_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
          requires :mcc_username
          requires :password
        end
        post do
          mcc_params = declared(params, include_missing: false)
          mcc = ProviderMcc.new(mcc_params)

          if mcc.save
            present mcc, with: Api::V1::Entities::ProviderMccEntity
          else
            error!({ errors: mcc.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_mccs/:id
          desc "Return a specific provider MCC record"
          get do
            mcc = ProviderMcc.find(params[:id])
            present mcc, with: Api::V1::Entities::ProviderMccEntity
          end

          # PUT /api/v1/provider_mccs/:id
          desc "Update a provider MCC record"
          params do
            use :shared_mcc_params
          end
          put do
            mcc = ProviderMcc.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)
            update_params.delete(:password) if update_params[:password].blank?

            if mcc.update(update_params)
              present mcc, with: Api::V1::Entities::ProviderMccEntity
            else
              error!({ errors: mcc.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_mccs/:id
          desc "Delete a provider MCC record"
          delete do
            mcc = ProviderMcc.find(params[:id])
            if mcc.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider MCC record"] }, 500)
            end
          end

        end
      end
    end
  end
end
