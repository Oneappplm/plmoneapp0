module Api
  module V1
    class EnrollmentGroupsDetailsQuestions < Grape::API

      helpers do
        params :shared_eg_detail_question_params do
          optional :secret_question, type: String, desc: 'The secret question text.'
          optional :answer, type: String, desc: 'The answer to the secret question.'
        end
      end

      resource :enrollment_groups_details_questions do

        # GET /api/v1/enrollment_groups_details_questions
        desc "Return a list of enrollment group detail questions"
        params do
          optional :enroll_groups_detail_id, type: Integer, desc: "Filter by EnrollGroupsDetail ID."
        end
        get do
          questions = EnrollmentGroupsDetailsQuestion.all
          questions = questions.where(enroll_groups_detail_id: params[:enroll_groups_detail_id]) if params[:enroll_groups_detail_id].present?
          present questions, with: Api::V1::Entities::EnrollmentGroupsDetailsQuestionEntity
        end

        # POST /api/v1/enrollment_groups_details_questions
        desc "Create an enrollment group detail question"
        params do
          use :shared_eg_detail_question_params
          requires :enroll_groups_detail_id, type: Integer, desc: 'ID of the associated EnrollGroupsDetail.'
          requires :secret_question
          requires :answer
        end
        post do
          question_params = declared(params, include_missing: false)
          question = EnrollmentGroupsDetailsQuestion.new(question_params)

          if question.save
            present question, with: Api::V1::Entities::EnrollmentGroupsDetailsQuestionEntity
          else
            error!({ errors: question.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/enrollment_groups_details_questions/:id
          desc "Return a specific enrollment group detail question"
          get do
            question = EnrollmentGroupsDetailsQuestion.find(params[:id])
            present question, with: Api::V1::Entities::EnrollmentGroupsDetailsQuestionEntity
          end

          # PUT /api/v1/enrollment_groups_details_questions/:id
          desc "Update an enrollment group detail question"
          params do
            use :shared_eg_detail_question_params
          end
          put do
            question = EnrollmentGroupsDetailsQuestion.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if question.update(update_params)
              present question, with: Api::V1::Entities::EnrollmentGroupsDetailsQuestionEntity
            else
              error!({ errors: question.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/enrollment_groups_details_questions/:id
          desc "Delete an enrollment group detail question"
          delete do
            question = EnrollmentGroupsDetailsQuestion.find(params[:id])
            if question.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete enrollment group detail question"] }, 500)
            end
          end

        end
      end
    end
  end
end
