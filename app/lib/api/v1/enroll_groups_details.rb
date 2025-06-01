module Api
  module V1
    class EnrollGroupsDetails < Grape::API

      helpers do
        params :shared_detail_params do
          optional :name, type: String, desc: "Name/key of the detail."
          optional :value, type: String, desc: "Value of the detail."
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
          optional :state_id, type: Integer
          optional :group_number, type: String
          optional :effective_date, type: DateTime
          optional :application_status, type: String
          optional :payor_type, type: String
          optional :medicare_tricare, type: String
          optional :payor_name, type: String
          optional :payor_phone, type: String
          optional :payor_email, type: String
          optional :enrollment_link, type: String
          optional :payor_username, type: String
          optional :password, type: String
          optional :payor_question, type: String
          optional :payor_answer, type: String
          optional :portal_admin, type: String
          optional :portal_admin_name, type: String
          optional :portal_admin_phone, type: String
          optional :portal_admin_email, type: String
          optional :caqh_payer, type: String
          optional :eft, type: String
          optional :era, type: String
          optional :client_notes, type: String
          optional :notes, type: String
          optional :payer_state, type: String
          optional :payor_submission_type, type: String
          optional :payor_link, type: String
          optional :portal_username, type: String
          optional :portal_password, type: String
          optional :upload_payor_file, type: JSON
        end
      end

      resource :enroll_group_details do

        # GET /api/v1/enroll_group_details
        desc "Return a list of enrollment group details"
        params do
          optional :enroll_group_id, type: Integer, desc: "Filter by parent EnrollGroup ID."
          optional :name, type: String, desc: "Filter by detail name/key."
        end
        get do
          details = EnrollGroupsDetail.all
          details = details.where(enroll_group_id: params[:enroll_group_id]) if params[:enroll_group_id].present?
          details = details.where(name: params[:name]) if params[:name].present?
          present details, with: Api::V1::Entities::EnrollGroupsDetailEntity
        end

        # POST /api/v1/enroll_group_details
        desc "Create a detail for an enrollment group"
        params do
          use :shared_detail_params
          requires :enroll_group_id, type: Integer, desc: "ID of the parent EnrollGroup."
        end
        post do
          detail_params = declared(params, include_missing: false)
          detail = EnrollGroupsDetail.new(detail_params)

          if detail.save
            present detail, with: Api::V1::Entities::EnrollGroupsDetailEntity
          else
            error!({ errors: detail.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/enroll_group_details/:id
          desc "Return a specific detail"
          get do
            detail = EnrollGroupsDetail.find(params[:id])
            present detail, with: Api::V1::Entities::EnrollGroupsDetailEntity
          end

          # PUT /api/v1/enroll_group_details/:id
          desc "Update a specific detail"
          params do
            use :shared_detail_params
          end
          put do
            detail = EnrollGroupsDetail.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if detail.update(update_params)
              present detail, with: Api::V1::Entities::EnrollGroupsDetailEntity
            else
              error!({ errors: detail.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/enroll_group_details/:id
          desc "Delete a specific detail"
          delete do
            detail = EnrollGroupsDetail.find(params[:id])
            if detail.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete detail"] }, 500)
            end
          end

        end
      end
    end
  end
end
