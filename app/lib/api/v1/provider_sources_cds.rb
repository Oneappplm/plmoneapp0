module Api
  module V1
    class ProviderSourcesCds < Grape::API

      helpers do
        params :shared_cds_params do
          optional :registration_number, type: String, desc: 'CDS registration number.'
          optional :state, type: String, desc: 'State associated with the CDS license.'
          optional :issue_date, type: DateTime, desc: 'CDS license issue date.'
          optional :expiration_date, type: DateTime, desc: 'CDS license expiration date.'
          optional :practicing_in_state, type: String, desc: 'Indicator if practicing in state.'
          optional :full_schedule, type: String, desc: 'Full schedule indicator.'
          optional :no_cds_explanation, type: String, desc: 'Explanation if no CDS license.'
          optional :schedule_limit_explanation, type: String, desc: 'Explanation for schedule limits.'
        end
      end

      resource :provider_sources_cds do

        # GET /api/v1/provider_sources_cds
        desc "Return a list of provider source CDS records"
        params do
          optional :provider_source_id, type: Integer, desc: "Filter by ProviderSource ID."
          optional :state, type: String, desc: "Filter by state."
        end
        get do
          cds_records = ProviderSourcesCds.all
          cds_records = cds_records.where(provider_source_id: params[:provider_source_id]) if params[:provider_source_id].present?
          cds_records = cds_records.where(state: params[:state]) if params[:state].present?
          present cds_records, with: Api::V1::Entities::ProviderSourcesCdsEntity
        end

        # POST /api/v1/provider_sources_cds
        desc "Create a provider source CDS record"
        params do
          use :shared_cds_params
          requires :provider_source_id, type: Integer, desc: 'ID of the associated ProviderSource.'
        end
        post do
          cds_params = declared(params, include_missing: false)
          cds_record = ProviderSourcesCds.new(cds_params)

          if cds_record.save
            present cds_record, with: Api::V1::Entities::ProviderSourcesCdsEntity
          else
            error!({ errors: cds_record.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_sources_cds/:id
          desc "Return a specific provider source CDS record"
          get do
            cds_record = ProviderSourcesCds.find(params[:id])
            present cds_record, with: Api::V1::Entities::ProviderSourcesCdsEntity
          end

          # PUT /api/v1/provider_sources_cds/:id
          desc "Update a provider source CDS record"
          params do
            use :shared_cds_params
          end
          put do
            cds_record = ProviderSourcesCds.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if cds_record.update(update_params)
              present cds_record, with: Api::V1::Entities::ProviderSourcesCdsEntity
            else
              error!({ errors: cds_record.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_sources_cds/:id
          desc "Delete a provider source CDS record"
          delete do
            cds_record = ProviderSourcesCds.find(params[:id])
            if cds_record.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider source CDS record"] }, 500)
            end
          end

        end
      end
    end
  end
end
