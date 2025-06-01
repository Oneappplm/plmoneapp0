module Api
  module V1
    class HelpCodes < Grape::API

      helpers do
        params :shared_help_code_params do
          requires :code, type: String, desc: 'Help code identifier'
          optional :description, type: String, desc: 'Description of the help code'
        end
      end

      resource :help_codes do

        # GET /api/v1/help_codes
        desc 'Return all help codes'
        get do
          help_codes = HelpCode.all
          present help_codes, with: Api::V1::Entities::HelpCodeEntity
        end

        # POST /api/v1/help_codes
        desc 'Create a help code'
        params do
          use :shared_help_code_params
        end
        post do
          help_code = HelpCode.new(declared(params, include_missing: false))

          if help_code.save
            present help_code, with: Api::V1::Entities::HelpCodeEntity
          else
            error!({ errors: help_code.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/help_codes/:id
          desc 'Return a specific help code'
          get do
            help_code = HelpCode.find(params[:id])
            present help_code, with: Api::V1::Entities::HelpCodeEntity
          end

          # PUT /api/v1/help_codes/:id
          desc 'Update a help code'
          params do
            use :shared_help_code_params
          end
          put do
            help_code = HelpCode.find(params[:id])
            update_params = declared(params, include_missing: false)

            if help_code.update(update_params)
              present help_code, with: Api::V1::Entities::HelpCodeEntity
            else
              error!({ errors: help_code.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/help_codes/:id
          desc 'Delete a help code'
          delete do
            help_code = HelpCode.find(params[:id])
            if help_code.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete help code'] }, 500)
            end
          end

        end
      end
    end
  end
end
