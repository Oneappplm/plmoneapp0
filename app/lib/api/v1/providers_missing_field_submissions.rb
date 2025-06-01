module Api
  module V1
    class ProvidersMissingFieldSubmissions < Grape::API

      helpers do
        params :shared_submission_params do
          optional :completed_by, type: Integer, desc: 'ID of the User who completed/submitted.'
          optional :status, type: String, desc: 'Status of the submission (e.g., pending, completed).'
        end
      end

      resource :providers_missing_field_submissions do

        # GET /api/v1/providers_missing_field_submissions
        desc "Return a list of providers missing field submissions"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
          optional :completed_by, type: Integer, desc: "Filter by User ID who completed."
          optional :status, type: String, desc: "Filter by status."
        end
        get do
          submissions = ProvidersMissingFieldSubmission.all
          submissions = submissions.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          submissions = submissions.where(completed_by: params[:completed_by]) if params[:completed_by].present?
          submissions = submissions.where(status: params[:status]) if params[:status].present?
          present submissions, with: Api::V1::Entities::ProvidersMissingFieldSubmissionEntity
        end

        # POST /api/v1/providers_missing_field_submissions
        desc "Create a providers missing field submission record"
        params do
          use :shared_submission_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
        end
        post do
          submission_params = declared(params, include_missing: false)
          submission = ProvidersMissingFieldSubmission.new(submission_params)

          if submission.save
            present submission, with: Api::V1::Entities::ProvidersMissingFieldSubmissionEntity
          else
            error!({ errors: submission.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/providers_missing_field_submissions/:id
          desc "Return a specific providers missing field submission record"
          get do
            submission = ProvidersMissingFieldSubmission.find(params[:id])
            present submission, with: Api::V1::Entities::ProvidersMissingFieldSubmissionEntity
          end

          # PUT /api/v1/providers_missing_field_submissions/:id
          desc "Update a providers missing field submission record"
          params do
            use :shared_submission_params
          end
          put do
            submission = ProvidersMissingFieldSubmission.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if submission.update(update_params)
              present submission, with: Api::V1::Entities::ProvidersMissingFieldSubmissionEntity
            else
              error!({ errors: submission.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/providers_missing_field_submissions/:id
          desc "Delete a providers missing field submission record"
          delete do
            submission = ProvidersMissingFieldSubmission.find(params[:id])
            if submission.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete providers missing field submission record"] }, 500)
            end
          end

        end
      end
    end
  end
end
