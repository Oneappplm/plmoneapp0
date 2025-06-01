module Api
  module V1
    module Entities
      class EnrollmentGroupDeletedDocLogs < Grape::API

        resource :enrollment_group_deleted_doc_logs do

          # GET /api/v1/enrollment_group_deleted_doc_logs
          desc "Return a list of enrollment group deleted document logs"
          params do
            optional :enrollment_group_id, type: Integer, desc: "Filter by EnrollmentGroup ID."
            optional :deleted_by, type: String, desc: "Filter by who deleted the document."
          end
          get do
            logs = EnrollmentGroupDeletedDocLog.all
            logs = logs.where(enrollment_group_id: params[:enrollment_group_id]) if params[:enrollment_group_id].present?
            logs = logs.where(deleted_by: params[:deleted_by]) if params[:deleted_by].present?
            present logs, with: Api::V1::Entities::EnrollmentGroupDeletedDocLogEntity
          end

          route_param :id do

            # GET /api/v1/enrollment_group_deleted_doc_logs/:id
            desc "Return a specific deleted document log record"
            get do
              log = EnrollmentGroupDeletedDocLog.find(params[:id])
              present log, with: Api::V1::Entities::EnrollmentGroupDeletedDocLogEntity
            end
          end
        end
      end
    end
  end
end
