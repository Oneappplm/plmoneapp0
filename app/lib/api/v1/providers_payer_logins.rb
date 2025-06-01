module Api
  module V1
    class ProvidersPayerLogins < Grape::API

      helpers do
        params :shared_payer_login_params do
          optional :enrollment_payer, type: String, desc: 'Name of the enrollment payer.'
          optional :state_id, type: Integer, desc: 'ID of the associated State.'
          optional :username, type: String, desc: 'Username for the payer login.'
          optional :notes, type: String, desc: 'Notes related to the payer login.'
          optional :cred_current_reattest_date, type: Date, desc: 'Credentialing current reattestation date.'
          optional :cred_reattest_date, type: Date, desc: 'Credentialing reattestation date.'
          optional :password, type: String, desc: 'Password for the payer login.'
        end
      end

      resource :providers_payer_logins do

        # GET /api/v1/providers_payer_logins
        desc "Return a list of provider payer logins"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
          optional :enrollment_payer, type: String, desc: "Filter by enrollment payer."
          optional :state_id, type: Integer, desc: "Filter by State ID."
        end
        get do
          logins = ProvidersPayerLogin.all
          logins = logins.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          logins = logins.where(enrollment_payer: params[:enrollment_payer]) if params[:enrollment_payer].present?
          logins = logins.where(state_id: params[:state_id]) if params[:state_id].present?
          present logins, with: Api::V1::Entities::ProvidersPayerLoginEntity
        end

        # POST /api/v1/providers_payer_logins
        desc "Create a provider payer login record"
        params do
          use :shared_payer_login_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
        end
        post do
          login_params = declared(params, include_missing: false)
          login = ProvidersPayerLogin.new(login_params)

          if login.save
            present login, with: Api::V1::Entities::ProvidersPayerLoginEntity
          else
            error!({ errors: login.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/providers_payer_logins/:id
          desc "Return a specific provider payer login record"
          get do
            login = ProvidersPayerLogin.find(params[:id])
            present login, with: Api::V1::Entities::ProvidersPayerLoginEntity
          end

          # PUT /api/v1/providers_payer_logins/:id
          desc "Update a provider payer login record"
          params do
            use :shared_payer_login_params
          end
          put do
            login = ProvidersPayerLogin.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)
            update_params.delete(:password) if update_params[:password].blank?

            if login.update(update_params)
              present login, with: Api::V1::Entities::ProvidersPayerLoginEntity
            else
              error!({ errors: login.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/providers_payer_logins/:id
          desc "Delete a provider payer login record"
          delete do
            login = ProvidersPayerLogin.find(params[:id])
            if login.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider payer login record"] }, 500)
            end
          end

        end
      end
    end
  end
end
