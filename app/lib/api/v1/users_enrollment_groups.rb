module Api
  module V1
    class UsersEnrollmentGroups < Grape::API
      resource :users_enrollment_groups do

        # GET /api/v1/users_enrollment_groups
        desc "Return a list of user-enrollment group associations"
        params do
          optional :user_id, type: Integer, desc: "Filter by User ID."
          optional :enrollment_group_id, type: Integer, desc: "Filter by Enrollment Group ID."
        end
        get do
          associations = UsersEnrollmentGroup.all
          associations = associations.where(user_id: params[:user_id]) if params[:user_id].present?
          associations = associations.where(enrollment_group_id: params[:enrollment_group_id]) if params[:enrollment_group_id].present?
          present associations, with: Api::V1::Entities::UsersEnrollmentGroupEntity
        end

        # POST /api/v1/users_enrollment_groups
        desc "Create a user-enrollment group association"
        params do
          requires :user_id, type: Integer, desc: "ID of the User."
          requires :enrollment_group_id, type: Integer, desc: "ID of the Enrollment Group."
        end
        post do
          assoc_params = declared(params, include_missing: false)
          association = UsersEnrollmentGroup.find_or_initialize_by(assoc_params)

          if association.new_record? && association.save
            present association, with: Api::V1::Entities::UsersEnrollmentGroupEntity
          elsif !association.new_record?
            present association, with: Api::V1::Entities::UsersEnrollmentGroupEntity
          else
            error!({ errors: association.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/users_enrollment_groups/:id
          desc "Return a specific user-enrollment group association"
          get do
            association = UsersEnrollmentGroup.find(params[:id])
            present association, with: Api::V1::Entities::UsersEnrollmentGroupEntity
          end

          # DELETE /api/v1/users_enrollment_groups/:id
          desc "Delete a specific user-enrollment group association"
          delete do
            association = UsersEnrollmentGroup.find(params[:id])
            if association.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete user-enrollment group association"] }, 500)
            end
          end

        end
      end
    end
  end
end
