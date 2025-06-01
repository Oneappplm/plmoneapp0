# app/lib/api/v1/egd_logs.rb
module Api
  module V1
    class EgdLogs < Grape::API

      helpers do
        params :shared_egd_log_params do
          requires :enroll_group_id, type: Integer, desc: 'ID of the associated enroll group'
          requires :action, type: String, desc: 'Action performed in the log'
          optional :notes, type: String, desc: 'Additional notes for the log entry'
        end
      end

      resource :egd_logs do

        # GET /api/v1/egd_logs
        desc 'Return all EGD logs'
        get do
          logs = EgdLog.all
          present logs, with: Api::V1::Entities::EgdLogEntity
        end

        # POST /api/v1/egd_logs
        desc 'Create an EGD log'
        params do
          use :shared_egd_log_params
        end
        post do
          log = EgdLog.new(declared(params, include_missing: false))

          if log.save
            present log, with: Api::V1::Entities::EgdLogEntity
          else
            error!({ errors: log.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/egd_logs/:id
          desc 'Return a specific EGD log'
          get do
            log = EgdLog.find(params[:id])
            present log, with: Api::V1::Entities::EgdLogEntity
          end

          # PUT /api/v1/egd_logs/:id
          desc 'Update an EGD log'
          params do
            use :shared_egd_log_params
          end
          put do
            log = EgdLog.find(params[:id])
            update_params = declared(params, include_missing: false)

            if log.update(update_params)
              present log, with: Api::V1::Entities::EgdLogEntity
            else
              error!({ errors: log.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/egd_logs/:id
          desc 'Delete an EGD log'
          delete do
            log = EgdLog.find(params[:id])
            if log.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete EGD log'] }, 500)
            end
          end

        end
      end
    end
  end
end
