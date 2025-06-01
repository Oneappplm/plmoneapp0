module Api
  module V1
    class ProviderMedicaids < Grape::API

      helpers do
        params :shared_medicaid_params do
          optional :effective_date, type: DateTime, desc: 'Medicaid effective date.'
          optional :reval_date, type: DateTime, desc: 'Medicaid revalidation date.'
          optional :notes, type: String, desc: 'Notes related to Medicaid enrollment.'
        end
      end

      resource :provider_medicaids do

        # GET /api/v1/provider_medicaids
        desc "Return a list of provider Medicaid records"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
        end
        get do
          medicaids = ProviderMedicaid.all
          medicaids = medicaids.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          present medicaids, with: Api::V1::Entities::ProviderMedicaidEntity
        end

        # POST /api/v1/provider_medicaids
        desc "Create a provider Medicaid record"
        params do
          use :shared_medicaid_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
        end
        post do
          medicaid_params = declared(params, include_missing: false)
          medicaid = ProviderMedicaid.new(medicaid_params)

          if medicaid.save
            present medicaid, with: Api::V1::Entities::ProviderMedicaidEntity
          else
            error!({ errors: medicaid.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_medicaids/:id
          desc "Return a specific provider Medicaid record"
          get do
            medicaid = ProviderMedicaid.find(params[:id])
            present medicaid, with: Api::V1::Entities::ProviderMedicaidEntity
          end

          # PUT /api/v1/provider_medicaids/:id
          desc "Update a provider Medicaid record"
          params do
            use :shared_medicaid_params
          end
          put do
            medicaid = ProviderMedicaid.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if medicaid.update(update_params)
              present medicaid, with: Api::V1::Entities::ProviderMedicaidEntity
            else
              error!({ errors: medicaid.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_medicaids/:id
          desc "Delete a provider Medicaid record"
          delete do
            medicaid = ProviderMedicaid.find(params[:id])
            if medicaid.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider Medicaid record"] }, 500)
            end
          end

        end
      end
    end
  end
end
