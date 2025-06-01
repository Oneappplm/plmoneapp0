module Api
  module V1
    class ProviderDeletedDocumentLogs < Grape::API

      helpers do
        params :shared_provider_deleted_document_log_params do
          requires :provider_id, type: Integer, desc: 'ID of the associated provider'
          requires :document_type, type: String, desc: 'Type of document deleted'
          optional :reason, type: String, desc: 'Reason for deletion'
        end
      end

      resource :provider_deleted_document_logs do

        # GET /api/v1/provider_deleted_document_logs
        desc 'Return all provider deleted document logs'
        get do
          logs = ProviderDeletedDocumentLog.all
          present logs, with: Api::V1::Entities::ProviderDeletedDocumentLogEntity
        end

        # POST /api/v1/provider_deleted_document_logs
        desc 'Create a provider deleted document log'
        params do
          use :shared_provider_deleted_document_log_params
        end
        post do
          log = ProviderDeletedDocumentLog.new(declared(params, include_missing: false))

          if log.save
            present log, with: Api::V1::Entities::ProviderDeletedDocumentLogEntity
          else
            error!({ errors: log.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_deleted_document_logs/:id
          desc 'Return a specific deleted document log'
          get do
            log = ProviderDeletedDocumentLog.find(params[:id])
            present log, with: Api::V1::Entities::ProviderDeletedDocumentLogEntity
          end

          # PUT /api/v1/provider_deleted_document_logs/:id
          desc 'Update a deleted document log'
          params do
            use :shared_provider_deleted_document_log_params
          end
          put do
            log = ProviderDeletedDocumentLog.find(params[:id])
            update_params = declared(params, include_missing: false)

            if log.update(update_params)
              present log, with: Api::V1::Entities::ProviderDeletedDocumentLogEntity
            else
              error!({ errors: log.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_deleted_document_logs/:id
          desc 'Delete a deleted document log'
          delete do
            log = ProviderDeletedDocumentLog.find(params[:id])
            if log.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete deleted document log'] }, 500)
            end
          end

        end
      end
    end
  end
end
