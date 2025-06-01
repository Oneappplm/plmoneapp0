module Api
  module V1
    class EnrollmentComments < Grape::API

      helpers do
        params :shared_comment_params do
          optional :body, type: String, desc: 'The content of the comment.'
        end
      end

      resource :enrollment_comments do

        # GET /api/v1/enrollment_comments
        desc "Return a list of enrollment comments"
        params do
          optional :enrollment_provider_id, type: Integer, desc: "Filter by EnrollmentProvider ID."
          optional :enroll_group_id, type: Integer, desc: "Filter by EnrollGroup ID."
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
          optional :user_id, type: Integer, desc: "Filter by User ID."
        end
        get do
          comments = EnrollmentComment.all
          comments = comments.where(enrollment_provider_id: params[:enrollment_provider_id]) if params[:enrollment_provider_id].present?
          comments = comments.where(enroll_group_id: params[:enroll_group_id]) if params[:enroll_group_id].present?
          comments = comments.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          comments = comments.where(user_id: params[:user_id]) if params[:user_id].present?
          present comments, with: Api::V1::Entities::EnrollmentCommentEntity
        end

        # POST /api/v1/enrollment_comments
        desc "Create an enrollment comment"
        params do
          use :shared_comment_params
          requires :user_id, type: Integer, desc: 'ID of the User making the comment.'
          requires :body
          optional :enrollment_provider_id, type: Integer, desc: 'ID of the associated EnrollmentProvider.'
          optional :enroll_group_id, type: Integer, desc: 'ID of the associated EnrollGroup.'
          optional :provider_id, type: Integer, desc: 'ID of the associated Provider.'
        end
        post do
          comment_params = declared(params, include_missing: false)
          comment = EnrollmentComment.new(comment_params)

          if comment.save
            present comment, with: Api::V1::Entities::EnrollmentCommentEntity
          else
            error!({ errors: comment.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/enrollment_comments/:id
          desc "Return a specific enrollment comment"
          get do
            comment = EnrollmentComment.find(params[:id])
            present comment, with: Api::V1::Entities::EnrollmentCommentEntity
          end

          # PUT /api/v1/enrollment_comments/:id
          desc "Update an enrollment comment"
          params do
            use :shared_comment_params
          end
          put do
            comment = EnrollmentComment.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if comment.update(update_params)
              present comment, with: Api::V1::Entities::EnrollmentCommentEntity
            else
              error!({ errors: comment.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/enrollment_comments/:id
          desc "Delete an enrollment comment"
          delete do
            comment = EnrollmentComment.find(params[:id])
            if comment.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete enrollment comment"] }, 500)
            end
          end

        end
      end
    end
  end
end
