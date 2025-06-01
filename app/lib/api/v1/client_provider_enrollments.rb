module Api
  module V1
    class ClientProviderEnrollments < Grape::API

      helpers do
        params :shared_client_provider_enrollment_params do
          requires :client_id, type: Integer, desc: 'Client ID'
          requires :provider_id, type: Integer, desc: 'Provider ID'
          optional :status, type: String, desc: 'Status of the enrollment'
        end
      end

      resource :client_provider_enrollments do

        # GET /api/v1/client_provider_enrollments
        desc 'Return all client provider enrollments'
        get do
          enrollments = ClientProviderEnrollment.all
          present enrollments, with: Api::V1::Entities::ClientProviderEnrollmentEntity
        end

        # POST /api/v1/client_provider_enrollments
        desc 'Create a client provider enrollment'
        params do
          use :shared_client_provider_enrollment_params
        end
        post do
          enrollment = ClientProviderEnrollment.new(declared(params, include_missing: false))

          if enrollment.save
            present enrollment, with: Api::V1::Entities::ClientProviderEnrollmentEntity
          else
            error!({ errors: enrollment.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/client_provider_enrollments/:id
          desc 'Return a specific client provider enrollment'
          get do
            enrollment = ClientProviderEnrollment.find(params[:id])
            present enrollment, with: Api::V1::Entities::ClientProviderEnrollmentEntity
          end

          # PUT /api/v1/client_provider_enrollments/:id
          desc 'Update a client provider enrollment'
          params do
            use :shared_client_provider_enrollment_params
          end
          put do
            enrollment = ClientProviderEnrollment.find(params[:id])
            update_params = declared(params, include_missing: false)

            if enrollment.update(update_params)
              present enrollment, with: Api::V1::Entities::ClientProviderEnrollmentEntity
            else
              error!({ errors: enrollment.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/client_provider_enrollments/:id
          desc 'Delete a client provider enrollment'
          delete do
            enrollment = ClientProviderEnrollment.find(params[:id])
            if enrollment.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete client provider enrollment'] }, 500)
            end
          end

        end
      end
    end
  end
end
