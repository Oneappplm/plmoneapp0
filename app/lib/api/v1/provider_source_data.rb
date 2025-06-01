module Api
  module V1
    class ProviderSourceData < Grape::API

      helpers do
        params :shared_data_params do
          optional :data_key, type: String, desc: 'Key identifying the data point.'
          optional :data_value, type: String, desc: 'Value of the data point.'
        end
      end

      resource :provider_source_data do

        # GET /api/v1/provider_source_data
        desc "Return a list of provider source data records"
        params do
          optional :provider_source_id, type: Integer, desc: "Filter by ProviderSource ID."
          optional :data_key, type: String, desc: "Filter by data key."
        end
        get do
          data_records = ProviderSourceData.all
          data_records = data_records.where(provider_source_id: params[:provider_source_id]) if params[:provider_source_id].present?
          data_records = data_records.where(data_key: params[:data_key]) if params[:data_key].present?
          present data_records, with: Api::V1::Entities::ProviderSourceDataEntity
        end

        # POST /api/v1/provider_source_data
        desc "Create a provider source data record"
        params do
          use :shared_data_params
          requires :provider_source_id, type: Integer, desc: 'ID of the associated ProviderSource.'
        end
        post do
          data_params = declared(params, include_missing: false)
          data_record = ProviderSourceData.new(data_params)

          if data_record.save
            present data_record, with: Api::V1::Entities::ProviderSourceDataEntity
          else
            error!({ errors: data_record.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_source_data/:id
          desc "Return a specific provider source data record"
          get do
            data_record = ProviderSourceData.find(params[:id])
            present data_record, with: Api::V1::Entities::ProviderSourceDataEntity
          end

          # PUT /api/v1/provider_source_data/:id
          desc "Update a provider source data record"
          params do
            use :shared_data_params
          end
          put do
            data_record = ProviderSourceData.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if data_record.update(update_params)
              present data_record, with: Api::V1::Entities::ProviderSourceDataEntity
            else
              error!({ errors: data_record.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_source_data/:id
          desc "Delete a provider source data record"
          delete do
            data_record = ProviderSourceData.find(params[:id])
            if data_record.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider source data record"] }, 500)
            end
          end

        end
      end
    end
  end
end
