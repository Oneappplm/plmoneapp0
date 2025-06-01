module Api
  module V1
    class EpdQuestions < Grape::API

      helpers do
        params :shared_epd_question_params do
          optional :question, type: String, desc: 'The question text.'
          optional :answer, type: String, desc: 'The answer text.'
        end
      end

      resource :epd_questions do

        # GET /api/v1/epd_questions
        desc "Return a list of EPD questions"
        params do
          optional :enrollment_providers_detail_id, type: Integer, desc: "Filter by EnrollmentProvidersDetail ID."
        end
        get do
          questions = EpdQuestion.all
          questions = questions.where(enrollment_providers_detail_id: params[:enrollment_providers_detail_id]) if params[:enrollment_providers_detail_id].present?
          present questions, with: Api::V1::Entities::EpdQuestionEntity
        end

        # POST /api/v1/epd_questions
        desc "Create an EPD question"
        params do
          use :shared_epd_question_params
          requires :enrollment_providers_detail_id, type: Integer, desc: 'ID of the associated EnrollmentProvidersDetail.'
        end
        post do
          question_params = declared(params, include_missing: false)
          question = EpdQuestion.new(question_params)

          if question.save
            present question, with: Api::V1::Entities::EpdQuestionEntity
          else
            error!({ errors: question.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/epd_questions/:id
          desc "Return a specific EPD question"
          get do
            question = EpdQuestion.find(params[:id])
            present question, with: Api::V1::Entities::EpdQuestionEntity
          end

          # PUT /api/v1/epd_questions/:id
          desc "Update an EPD question"
          params do
            use :shared_epd_question_params
          end
          put do
            question = EpdQuestion.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if question.update(update_params)
              present question, with: Api::V1::Entities::EpdQuestionEntity
            else
              error!({ errors: question.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/epd_questions/:id
          desc "Delete an EPD question"
          delete do
            question = EpdQuestion.find(params[:id])
            if question.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete EPD question"] }, 500)
            end
          end

        end
      end
    end
  end
end
