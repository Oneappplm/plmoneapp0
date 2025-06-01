module Api
  module V1
    class ProvidersMissingFieldSubmissionsData < Grape::API

      helpers do
        params :shared_submission_data_params do
          optional :data_attribute, type: String, desc: 'The attribute name of the missing field.'
          optional :data_key, type: String, desc: 'A key related to the data (if applicable).'
          optional :data_value, type: String, desc: 'The submitted value for the missing field.'
        end
      end

      resource :providers_missing_field_submissions_data do

        # GET /api/v1/providers_missing_field_submissions_data
        desc "Return a list of providers missing field submissions data"
        params do
          optional :providers_missing_field_submission_id, type: Integer, desc: "Filter by parent submission ID."
          optional :data_attribute, type: String, desc: "Filter by data attribute."
        end
        get do
          data_records = ProvidersMissingFieldSubmissionsData.all
          data_records = data_records.where(providers_missing_field_submission_id: params[:providers_missing_field_submission_id]) if params[:providers_missing_field_submission_id].present?
          data_records = data_records.where(data_attribute: params[:data_attribute]) if params[:data_attribute].present?
          present data_records, with: Api::V1::Entities::ProvidersMissingFieldSubmissionsDataEntity
        end

        # POST /api/v1/providers_missing_field_submissions_data
        desc "Create a providers missing field submissions data record"
        params do
          use :shared_submission_data_params
          requires :providers_missing_field_submission_id, type: Integer, desc: 'ID of the parent ProvidersMissingFieldSubmission.'
        end
        post do
          data_params = declared(params, include_missing: false)
          data_record = ProvidersMissingFieldSubmissionsData.new(data_params)

          if data_record.save
            present data_record, with: Api::V1::Entities::ProvidersMissingFieldSubmissionsDataEntity
          else
            error!({ errors: data_record.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/providers_missing_field_submissions_data/:id
          desc "Return a specific providers missing field submissions data record"
          get do
            data_record = ProvidersMissingFieldSubmissionsData.find(params[:id])
            present data_record, with: Api::V1::Entities::ProvidersMissingFieldSubmissionsDataEntity
          end

          # PUT /api/v1/providers_missing_field_submissions_data/:id
          desc "Update a providers missing field submissions data record"
          params do
            use :shared_submission_data_params
          end
          put do
            data_record = ProvidersMissingFieldSubmissionsData.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if data_record.update(update_params)
              present data_record, with: Api::V1::Entities::ProvidersMissingFieldSubmissionsDataEntity
            else
              error!({ errors: data_record.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/providers_missing_field_submissions_data/:id
          desc "Delete a providers missing field submissions data record"
          delete do
            data_record = ProvidersMissingFieldSubmissionsData.find(params[:id])
            if data_record.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete providers missing field submissions data record"] }, 500)
            end
          end

        end
      end
    end
  end
end
