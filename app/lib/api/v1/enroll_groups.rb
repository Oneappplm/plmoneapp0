module Api
  module V1
    class EnrollGroups < Grape::API

      helpers do
        params :shared_enroll_group_params do
          optional :name, type: String, desc: 'Name of the enrollment group.'
          optional :first_name, type: String
          optional :middle_name, type: String
          optional :last_name, type: String
          optional :suffix, type: String
          optional :email, type: String, desc: 'Contact email for the group.'
          optional :telephone_number, type: String, desc: 'Contact telephone number.'
          optional :medicare_ptan, type: String
          optional :medicaid_group_number, type: String
          optional :bcbs_number, type: String
          optional :tricate_military, type: String
          optional :commercial_name, type: String
          optional :contracted, type: String
          optional :revalidated, type: String
          optional :revalidated_payer_name, type: String
          optional :application_contracts, type: String
          optional :application_payer_name, type: String
          optional :with_medicare, type: String
          optional :with_eft, type: String
          optional :with_edi, type: String
          optional :start_date, type: DateTime, desc: 'Enrollment start date.'
          optional :due_date, type: DateTime, desc: 'Enrollment due date.'
          optional :payer, type: String, desc: 'Associated payer.'
          optional :revalidation_date, type: DateTime, desc: 'Revalidation date.'
          optional :enrollment_type, type: String, desc: 'Type of enrollment.'
          optional :status, type: String, desc: 'Current status of the enrollment group.'
          optional :group_id, type: Integer, desc: 'Associated Group ID (if applicable).'
          optional :user_id, type: Integer, desc: 'ID of the associated User.'
          optional :outreach_type, type: String
          optional :enrollment_payer, type: String, desc: 'Specific enrollment payer.'
          optional :voided_bank_letter, type: String
          optional :dco, type: Integer
        end
      end

      resource :enroll_groups do

        # GET /api/v1/enroll_groups
        desc "Return a list of enrollment groups"
        params do
          optional :user_id, type: Integer, desc: "Filter by User ID."
          optional :status, type: String, desc: "Filter by status."
          optional :payer, type: String, desc: "Filter by payer."
        end
        get do
          groups = EnrollGroup.all
          groups = groups.where(user_id: params[:user_id]) if params[:user_id].present?
          groups = groups.where(status: params[:status]) if params[:status].present?
          groups = groups.where(payer: params[:payer]) if params[:payer].present?
          present groups, with: Api::V1::Entities::EnrollGroupEntity
        end

        # POST /api/v1/enroll_groups
        desc "Create an enrollment group"
        params do
          use :shared_enroll_group_params
        end
        post do
          group_params = declared(params, include_missing: false)
          group = EnrollGroup.new(group_params)

          if group.save
            present group, with: Api::V1::Entities::EnrollGroupEntity
          else
            error!({ errors: group.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/enroll_groups/:id
          desc "Return a specific enrollment group"
          get do
            group = EnrollGroup.find(params[:id])
            present group, with: Api::V1::Entities::EnrollGroupEntity
          end

          # PUT /api/v1/enroll_groups/:id
          desc "Update an enrollment group"
          params do
            use :shared_enroll_group_params
          end
          put do
            group = EnrollGroup.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if group.update(update_params)
              present group, with: Api::V1::Entities::EnrollGroupEntity
            else
              error!({ errors: group.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/enroll_groups/:id
          desc "Delete an enrollment group"
          delete do
            group = EnrollGroup.find(params[:id])
            if group.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete enrollment group"] }, 500)
            end
          end

        end
      end
    end
  end
end
