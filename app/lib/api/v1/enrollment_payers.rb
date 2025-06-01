module Api
  module V1
    class EnrollmentPayers < Grape::API

      helpers do
        params :shared_payer_params do
          optional :name, type: String, desc: 'Name of the enrollment payer.'
        end
      end

      resource :enrollment_payers do

        # GET /api/v1/enrollment_payers
        desc "Return a list of enrollment payers"
        get do
          payers = EnrollmentPayer.all
          present payers, with: Api::V1::Entities::EnrollmentPayerEntity
        end

        # POST /api/v1/enrollment_payers
        desc "Create an enrollment payer"
        params do
          use :shared_payer_params
          requires :name
        end
        post do
          payer_params = declared(params, include_missing: false)
          payer = EnrollmentPayer.new(payer_params)

          if payer.save
            present payer, with: Api::V1::Entities::EnrollmentPayerEntity
          else
            error!({ errors: payer.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/enrollment_payers/:id
          desc "Return a specific enrollment payer"
          get do
            payer = EnrollmentPayer.find(params[:id])
            present payer, with: Api::V1::Entities::EnrollmentPayerEntity
          end

          # PUT /api/v1/enrollment_payers/:id
          desc "Update an enrollment payer"
          params do
            use :shared_payer_params
            requires :name
          end
          put do
            payer = EnrollmentPayer.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if payer.update(update_params)
              present payer, with: Api::V1::Entities::EnrollmentPayerEntity
            else
              error!({ errors: payer.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/enrollment_payers/:id
          desc "Delete an enrollment payer"
          delete do
            payer = EnrollmentPayer.find(params[:id])
            if payer.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete enrollment payer"] }, 500)
            end
          end

        end
      end
    end
  end
end
