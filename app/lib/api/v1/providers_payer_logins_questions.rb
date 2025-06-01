module Api
  module V1
    class ProvidersPayerLoginsQuestions < Grape::API

      helpers do
        params :shared_payer_login_question_params do
          optional :question, type: String, desc: 'The security question text.'
          optional :answer, type: String, desc: 'The answer to the security question.' # Sensitive?
        end
      end

      resource :providers_payer_logins_questions do

        # GET /api/v1/providers_payer_logins_questions
        desc "Return a list of provider payer login questions"
        params do
          optional :providers_payer_login_id, type: Integer, desc: "Filter by ProvidersPayerLogin ID."
        end
        get do
          questions = ProvidersPayerLoginsQuestion.all
          questions = questions.where(providers_payer_login_id: params[:providers_payer_login_id]) if params[:providers_payer_login_id].present?
          present questions, with: Api::V1::Entities::ProvidersPayerLoginsQuestionEntity
        end

        # POST /api/v1/providers_payer_logins_questions
        desc "Create a provider payer login question record"
        params do
          use :shared_payer_login_question_params
          requires :providers_payer_login_id, type: Integer, desc: 'ID of the associated ProvidersPayerLogin.'
        end
        post do
          question_params = declared(params, include_missing: false)
          question = ProvidersPayerLoginsQuestion.new(question_params)

          if question.save
            present question, with: Api::V1::Entities::ProvidersPayerLoginsQuestionEntity
          else
            error!({ errors: question.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/providers_payer_logins_questions/:id
          desc "Return a specific provider payer login question record"
          get do
            question = ProvidersPayerLoginsQuestion.find(params[:id])
            present question, with: Api::V1::Entities::ProvidersPayerLoginsQuestionEntity
          end

          # PUT /api/v1/providers_payer_logins_questions/:id
          desc "Update a provider payer login question record"
          params do
            use :shared_payer_login_question_params
          end
          put do
            question = ProvidersPayerLoginsQuestion.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if question.update(update_params)
              present question, with: Api::V1::Entities::ProvidersPayerLoginsQuestionEntity
            else
              error!({ errors: question.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/providers_payer_logins_questions/:id
          desc "Delete a provider payer login question record"
          delete do
            question = ProvidersPayerLoginsQuestion.find(params[:id])
            if question.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider payer login question record"] }, 500)
            end
          end

        end
      end
    end
  end
end
