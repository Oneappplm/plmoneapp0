module Api
  module V1
    class WorkHistoryProviders < Grape::API

      helpers do
        params :shared_work_history_params do
          optional :practice_name, type: String, desc: 'Name of the practice.'
          optional :location, type: String, desc: 'Location of the practice.'
          optional :start_date, type: Date, desc: 'Start date of employment.'
          optional :end_date, type: Date, desc: 'End date of employment.'
          optional :tax_id, type: Integer, desc: 'Tax ID associated with the practice.'
          optional :reasone_of_leaving, type: String, desc: 'Reason for leaving the practice.' # Typo matches schema
        end
      end

      resource :work_history_providers do

        # GET /api/v1/work_history_providers
        desc "Return a list of provider work history records"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
        end
        get do
          histories = WorkHistoryProvider.all
          histories = histories.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          present histories, with: Api::V1::Entities::WorkHistoryProviderEntity
        end

        # POST /api/v1/work_history_providers
        desc "Create a provider work history record"
        params do
          use :shared_work_history_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
          requires :practice_name
          requires :start_date
        end
        post do
          history_params = declared(params, include_missing: false)
          history = WorkHistoryProvider.new(history_params)

          if history.save
            present history, with: Api::V1::Entities::WorkHistoryProviderEntity
          else
            error!({ errors: history.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/work_history_providers/:id
          desc "Return a specific provider work history record"
          get do
            history = WorkHistoryProvider.find(params[:id])
            present history, with: Api::V1::Entities::WorkHistoryProviderEntity
          end

          # PUT /api/v1/work_history_providers/:id
          desc "Update a provider work history record"
          params do
            use :shared_work_history_params
            # provider_id is typically not changed on update
          end
          put do
            history = WorkHistoryProvider.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if history.update(update_params)
              present history, with: Api::V1::Entities::WorkHistoryProviderEntity
            else
              error!({ errors: history.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/work_history_providers/:id
          desc "Delete a provider work history record"
          delete do
            history = WorkHistoryProvider.find(params[:id])
            if history.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider work history record"] }, 500)
            end
          end

        end
      end
    end
  end
end
