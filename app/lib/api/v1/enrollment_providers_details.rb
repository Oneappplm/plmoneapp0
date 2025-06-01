module Api
  module V1
    class EnrollmentProvidersDetails < Grape::API

      helpers do
        params :shared_ep_detail_params do
          optional :start_date, type: Date
          optional :due_date, type: Date
          optional :enrollment_payer, type: String
          optional :enrollment_type, type: String
          optional :enrollment_status, type: String
          optional :ptan_number, type: String
          optional :approved_date, type: Date
          optional :revalidation_date, type: Date
          optional :revalidation_due_date, type: Date
          optional :comment, type: String
          optional :provider_ptan, type: String
          optional :group_ptan, type: String
          optional :enrollment_tracking_id, type: Integer
          optional :enrollment_effective_date, type: String
          optional :association_start_date, type: String
          optional :business_end_date, type: String
          optional :association_end_date, type: String
          optional :line_of_business, type: String
          optional :revalidation_status, type: String
          optional :cpt_code, type: String
          optional :descriptor, type: String
          optional :provider_id, type: String
          optional :group_id, type: String
          optional :payer_state, type: String
          optional :upload_payor_file, type: JSON
          optional :payor_username, type: String
          optional :payor_password, type: String
          optional :processing_date, type: String
          optional :terminated_date, type: String
          optional :denied_date, type: Date
          optional :payor_email, type: String
          optional :payor_phone, type: String
          optional :tax_id, type: String
          optional :location, type: String
        end
      end

      resource :enrollment_providers_details do

        # GET /api/v1/enrollment_providers_details
        desc "Return a list of enrollment provider details"
        params do
          optional :enrollment_provider_id, type: Integer, desc: "Filter by parent EnrollmentProvider ID."
          optional :enrollment_status, type: String, desc: "Filter by enrollment status."
          optional :enrollment_payer, type: String, desc: "Filter by enrollment payer."
        end
        get do
          details = EnrollmentProvidersDetail.all
          details = details.where(enrollment_provider_id: params[:enrollment_provider_id]) if params[:enrollment_provider_id].present?
          details = details.where(enrollment_status: params[:enrollment_status]) if params[:enrollment_status].present?
          details = details.where(enrollment_payer: params[:enrollment_payer]) if params[:enrollment_payer].present?
          present details, with: Api::V1::Entities::EnrollmentProvidersDetailEntity
        end

        # POST /api/v1/enrollment_providers_details
        desc "Create an enrollment provider detail record"
        params do
          use :shared_ep_detail_params
          requires :enrollment_provider_id, type: Integer, desc: 'ID of the parent EnrollmentProvider.'
        end
        post do
          detail_params = declared(params, include_missing: false)
          detail = EnrollmentProvidersDetail.new(detail_params)

          if detail.save
            present detail, with: Api::V1::Entities::EnrollmentProvidersDetailEntity
          else
            error!({ errors: detail.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/enrollment_providers_details/:id
          desc "Return a specific enrollment provider detail record"
          get do
            detail = EnrollmentProvidersDetail.find(params[:id])
            present detail, with: Api::V1::Entities::EnrollmentProvidersDetailEntity
          end

          # PUT /api/v1/enrollment_providers_details/:id
          desc "Update an enrollment provider detail record"
          params do
            use :shared_ep_detail_params
          end
          put do
            detail = EnrollmentProvidersDetail.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if detail.update(update_params)
              present detail, with: Api::V1::Entities::EnrollmentProvidersDetailEntity
            else
              error!({ errors: detail.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/enrollment_providers_details/:id
          desc "Delete an enrollment provider detail record"
          delete do
            detail = EnrollmentProvidersDetail.find(params[:id])
            if detail.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete enrollment provider detail record"] }, 500)
            end
          end

        end
      end
    end
  end
end
