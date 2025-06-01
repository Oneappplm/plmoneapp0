module Api
  module V1
    class EpdLogs < Grape::API

      helpers do
        params :shared_epd_log_params do
          requires :enrollment_provider_id, type: Integer, desc: 'ID of the associated EnrollmentProvider'
          requires :action, type: String, desc: 'Action performed in the log'
          optional :notes, type: String, desc: 'Additional notes for the log entry'
        end
      end

      resource :epd_logs do

        # GET /api/v1/epd_logs
        desc 'Return all EPD logs'
        get do
          logs = EpdLog.all
          present logs, with: Api::V1::Entities::EpdLogEntity
        end

        # POST /api/v1/epd_logs
        desc 'Create an EPD log'
        params do
          use :shared_epd_log_params
        end
        post do
          log = EpdLog.new(declared(params, include_missing: false))

          if log.save
            present log, with: Api::V1::Entities::EpdLogEntity
          else
            error!({ errors: log.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/epd_logs/:id
          desc 'Return a specific EPD log'
          get do
            log = EpdLog.find(params[:id])
            present log, with: Api::V1::Entities::EpdLogEntity
          end

          # PUT /api/v1/epd_logs/:id
          desc 'Update an EPD log'
          params do
            use :shared_epd_log_params
          end
          put do
            log = EpdLog.find(params[:id])
            update_params = declared(params, include_missing: false)

            if log.update(update_params)
              present log, with: Api::V1::Entities::EpdLogEntity
            else
              error!({ errors: log.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/epd_logs/:id
          desc 'Delete an EPD log'
          delete do
            log = EpdLog.find(params[:id])
            if log.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete EPD log'] }, 500)
            end
          end

        end
      end
    end
  end
end
