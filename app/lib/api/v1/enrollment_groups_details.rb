module Api
  module V1
    class EnrollmentGroupsDetails < Grape::API

      helpers do
        params :shared_eg_ownership_params do
          optional :individual_ownership_first_name, type: String
          optional :individual_ownership_middle_name, type: String
          optional :individual_ownership_last_name, type: String
          optional :individual_ownership_title, type: String
          optional :individual_ownership_ssn, type: String
          optional :individual_ownership_dob, type: String
          optional :individual_ownership_percent_of_ownership, type: String
          optional :individual_ownership_effective_date, type: Date
          optional :individual_ownership_control_date, type: Date
          optional :roles, type: String
          optional :email_address, type: String
          optional :group_role, type: String
        end
      end

      resource :enrollment_groups_details do

        # GET /api/v1/enrollment_groups_details
        desc "Return a list of enrollment group ownership details"
        params do
          optional :enrollment_group_id, type: Integer, desc: "Filter by EnrollmentGroup ID."
        end
        get do
          details = EnrollmentGroupsDetail.all
          details = details.where(enrollment_group_id: params[:enrollment_group_id]) if params[:enrollment_group_id].present?
          present details, with: Api::V1::Entities::EnrollmentGroupsDetailOwnershipEntity
        end

        # POST /api/v1/enrollment_groups_details
        desc "Create an enrollment group ownership detail"
        params do
          use :shared_eg_ownership_params
          requires :enrollment_group_id, type: Integer, desc: 'ID of the associated EnrollmentGroup.'
        end
        post do
          detail_params = declared(params, include_missing: false)
          detail = EnrollmentGroupsDetail.new(detail_params)

          if detail.save
            present detail, with: Api::V1::Entities::EnrollmentGroupsDetailOwnershipEntity
          else
            error!({ errors: detail.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/enrollment_groups_details/:id
          desc "Return a specific enrollment group ownership detail"
          get do
            detail = EnrollmentGroupsDetail.find(params[:id])
            present detail, with: Api::V1::Entities::EnrollmentGroupsDetailOwnershipEntity
          end

          # PUT /api/v1/enrollment_groups_details/:id
          desc "Update an enrollment group ownership detail"
          params do
            use :shared_eg_ownership_params
          end
          put do
            # Use correct singular model name
            detail = EnrollmentGroupsDetail.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if detail.update(update_params)
              present detail, with: Api::V1::Entities::EnrollmentGroupsDetailOwnershipEntity
            else
              error!({ errors: detail.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/enrollment_groups_details/:id
          desc "Delete an enrollment group ownership detail"
          delete do
            detail = EnrollmentGroupsDetail.find(params[:id])
            if detail.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete enrollment group ownership detail"] }, 500)
            end
          end

        end
      end
    end
  end
end
