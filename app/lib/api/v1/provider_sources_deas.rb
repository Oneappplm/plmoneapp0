module Api
  module V1
    class ProviderSourcesDeas < Grape::API

      helpers do
        params :shared_dea_params do
          optional :registration_number, type: String, desc: 'DEA registration number.'
          optional :state, type: String, desc: 'State associated with the DEA license.'
          optional :issue_date, type: Date, desc: 'DEA license issue date.'
          optional :expiration_date, type: Date, desc: 'DEA license expiration date.'
          optional :full_schedule, type: String, desc: 'Full schedule indicator.'
          optional :does_not_expire, type: String, desc: 'Indicator if license does not expire.'
          optional :schedule_limit_explanation, type: String, desc: 'Explanation for schedule limits.'
          optional :schedule_helds, type: String, desc: 'Schedules held.'
        end
      end

      resource :provider_sources_deas do

        # GET /api/v1/provider_sources_deas
        desc "Return a list of provider source DEA records"
        params do
          optional :provider_source_id, type: Integer, desc: "Filter by ProviderSource ID."
          optional :state, type: String, desc: "Filter by state."
        end
        get do
          dea_records = ProviderSourcesDea.all
          dea_records = dea_records.where(provider_source_id: params[:provider_source_id]) if params[:provider_source_id].present?
          dea_records = dea_records.where(state: params[:state]) if params[:state].present?
          present dea_records, with: Api::V1::Entities::ProviderSourcesDeaEntity
        end

        # POST /api/v1/provider_sources_deas
        desc "Create a provider source DEA record"
        params do
          use :shared_dea_params
          requires :provider_source_id, type: Integer, desc: 'ID of the associated ProviderSource.'
        end
        post do
          dea_params = declared(params, include_missing: false)
          dea_record = ProviderSourcesDea.new(dea_params)

          if dea_record.save
            present dea_record, with: Api::V1::Entities::ProviderSourcesDeaEntity
          else
            error!({ errors: dea_record.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_sources_deas/:id
          desc "Return a specific provider source DEA record"
          get do
            dea_record = ProviderSourcesDea.find(params[:id])
            present dea_record, with: Api::V1::Entities::ProviderSourcesDeaEntity
          end

          # PUT /api/v1/provider_sources_deas/:id
          desc "Update a provider source DEA record"
          params do
            use :shared_dea_params
          end
          put do
            dea_record = ProviderSourcesDea.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if dea_record.update(update_params)
              present dea_record, with: Api::V1::Entities::ProviderSourcesDeaEntity
            else
              error!({ errors: dea_record.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_sources_deas/:id
          desc "Delete a provider source DEA record"
          delete do
            dea_record = ProviderSourcesDea.find(params[:id])
            if dea_record.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider source DEA record"] }, 500)
            end
          end

        end
      end
    end
  end
end
