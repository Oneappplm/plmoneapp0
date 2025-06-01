module Api
  module V1
    class DisclosureQuestions < Grape::API

      helpers do
        params :shared_question_params do
          optional :question, type: String, desc: 'The text of the question.'
          optional :slug, type: String, desc: 'Unique slug for the question.'
          optional :note, type: String, desc: 'Note associated with the question.'
          optional :alert_type, type: String, desc: 'Type of alert associated with the question.'
        end
      end

      resource :disclosure_questions do

        # GET /api/v1/disclosure_questions
        desc "Return a list of disclosure questions"
        params do
          optional :disclosure_category_id, type: Integer, desc: "Filter by DisclosureCategory ID."
        end
        get do
          questions = DisclosureQuestion.all
          questions = questions.where(disclosure_category_id: params[:disclosure_category_id]) if params[:disclosure_category_id].present?
          present questions, with: Api::V1::Entities::DisclosureQuestionEntity
        end

        # POST /api/v1/disclosure_questions
        desc "Create a disclosure question"
        params do
          use :shared_question_params
          requires :disclosure_category_id, type: Integer, desc: 'ID of the associated DisclosureCategory.'
        end
        post do
          question_params = declared(params, include_missing: false)
          question = DisclosureQuestion.new(question_params)

          if question.save
            present question, with: Api::V1::Entities::DisclosureQuestionEntity
          else
            error!({ errors: question.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/disclosure_questions/:id
          desc "Return a specific disclosure question"
          get do
            question = DisclosureQuestion.find(params[:id])
            present question, with: Api::V1::Entities::DisclosureQuestionEntity
          end

          # PUT /api/v1/disclosure_questions/:id
          desc "Update a disclosure question"
          params do
            use :shared_question_params
          end
          put do
            question = DisclosureQuestion.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if question.update(update_params)
              present question, with: Api::V1::Entities::DisclosureQuestionEntity
            else
              error!({ errors: question.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/disclosure_questions/:id
          desc "Delete a disclosure question"
          delete do
            question = DisclosureQuestion.find(params[:id])
            if question.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete disclosure question"] }, 500)
            end
          end

        end
      end
    end
  end
end
