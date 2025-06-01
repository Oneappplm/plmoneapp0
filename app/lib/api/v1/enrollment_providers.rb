module Api
  module V1
    class EnrollmentProviders < Grape::API

      helpers do
        params :shared_enrollment_provider_params do
          optional :provider_id, type: Integer, desc: 'ID of the associated Provider.'
          optional :user_id, type: Integer, desc: 'ID of the associated User.'
          optional :name, type: String, desc: 'Name associated with the enrollment.'
          optional :first_name, type: String
          optional :middle_name, type: String
          optional :last_name, type: String
          optional :suffix, type: String
          optional :telephone_number, type: String
          optional :email_address, type: String
          optional :start_date, type: DateTime
          optional :due_date, type: DateTime
          optional :enrollment_payer, type: String
          optional :revalidation_date, type: DateTime
          optional :enrollment_type, type: String
          optional :status, type: String
          optional :application_id, type: String
          optional :approved_date, type: DateTime
          optional :approved_confirmation, type: String
          optional :outreach_type, type: String
          optional :enrolled_by, type: String
          optional :updated_by, type: String
          optional :state_license_submitted, type: DateTime
          optional :dea_submitted, type: DateTime
          optional :irs_letter_submitted, type: DateTime
          optional :w9_submitted, type: DateTime
          optional :voided_check_submitted, type: DateTime
          optional :curriculum_vitae_submitted, type: DateTime
          optional :cms_460_submitted, type: DateTime
          optional :eft_submitted, type: DateTime
          optional :cert_insurance_submitted, type: DateTime
          optional :driver_license_submitted, type: DateTime
          optional :board_certification_submitted, type: DateTime
          optional :not_submitted_note, type: String
          optional :not_submitted_note_rejected, type: String
        end
      end

      resource :enrollment_providers do

        # GET /api/v1/enrollment_providers
        desc "Return a list of enrollment provider records"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
          optional :user_id, type: Integer, desc: "Filter by User ID."
          optional :status, type: String, desc: "Filter by status."
          optional :enrollment_payer, type: String, desc: "Filter by enrollment payer."
        end
        get do
          enrollments = EnrollmentProvider.all
          enrollments = enrollments.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          enrollments = enrollments.where(user_id: params[:user_id]) if params[:user_id].present?
          enrollments = enrollments.where(status: params[:status]) if params[:status].present?
          enrollments = enrollments.where(enrollment_payer: params[:enrollment_payer]) if params[:enrollment_payer].present?
          present enrollments, with: Api::V1::Entities::EnrollmentProviderEntity
        end

        # POST /api/v1/enrollment_providers
        desc "Create an enrollment provider record"
        params do
          use :shared_enrollment_provider_params
          requires :provider_id
          requires :user_id
          requires :enrollment_payer
        end
        post do
          enrollment_params = declared(params, include_missing: false)
          enrollment = EnrollmentProvider.new(enrollment_params)

          if enrollment.save
            present enrollment, with: Api::V1::Entities::EnrollmentProviderEntity
          else
            error!({ errors: enrollment.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/enrollment_providers/:id
          desc "Return a specific enrollment provider record"
          get do
            enrollment = EnrollmentProvider.find(params[:id])
            present enrollment, with: Api::V1::Entities::EnrollmentProviderEntity
          end

          # PUT /api/v1/enrollment_providers/:id
          desc "Update an enrollment provider record"
          params do
            use :shared_enrollment_provider_params
          end
          put do
            enrollment = EnrollmentProvider.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if enrollment.update(update_params)
              present enrollment, with: Api::V1::Entities::EnrollmentProviderEntity
            else
              error!({ errors: enrollment.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/enrollment_providers/:id
          desc "Delete an enrollment provider record"
          delete do
            enrollment = EnrollmentProvider.find(params[:id])
            if enrollment.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete enrollment provider record"] }, 500)
            end
          end

        end
      end
    end
  end
end
