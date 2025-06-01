module Api
  module V1
    class ProviderSourceDocuments < Grape::API

      helpers do
        params :shared_provider_source_document_params do
          requires :provider_source_id, type: Integer, desc: 'Associated ProviderSource ID'
          requires :document_type, type: String, desc: 'Type of document'
          optional :file_url, type: String, desc: 'URL of the uploaded document file'
        end
      end

      resource :provider_source_documents do

        # GET /api/v1/provider_source_documents
        desc 'Return all provider source documents'
        get do
          documents = ProviderSourceDocument.all
          present documents, with: Api::V1::Entities::ProviderSourceDocumentEntity
        end

        # POST /api/v1/provider_source_documents
        desc 'Create a provider source document'
        params do
          use :shared_provider_source_document_params
        end
        post do
          document = ProviderSourceDocument.new(declared(params, include_missing: false))

          if document.save
            present document, with: Api::V1::Entities::ProviderSourceDocumentEntity
          else
            error!({ errors: document.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_source_documents/:id
          desc 'Return a specific provider source document'
          get do
            document = ProviderSourceDocument.find(params[:id])
            present document, with: Api::V1::Entities::ProviderSourceDocumentEntity
          end

          # PUT /api/v1/provider_source_documents/:id
          desc 'Update a provider source document'
          params do
            use :shared_provider_source_document_params
          end
          put do
            document = ProviderSourceDocument.find(params[:id])
            update_params = declared(params, include_missing: false)

            if document.update(update_params)
              present document, with: Api::V1::Entities::ProviderSourceDocumentEntity
            else
              error!({ errors: document.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_source_documents/:id
          desc 'Delete a provider source document'
          delete do
            document = ProviderSourceDocument.find(params[:id])
            if document.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete provider source document'] }, 500)
            end
          end

        end
      end
    end
  end
end
