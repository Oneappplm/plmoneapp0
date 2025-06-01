module Api
  module V1
    class GroupDcoSchedules < Grape::API

      helpers do
        params :shared_schedule_params do
          optional :day, type: String, desc: 'Day of the week for the schedule.'
          optional :start_time, type: String, desc: 'Start time for the schedule.'
          optional :end_time, type: String, desc: 'End time for the schedule.'
        end
      end

      resource :group_dco_schedules do

        # GET /api/v1/group_dco_schedules
        desc "Return a list of group DCO schedules"
        params do
          optional :group_dco_id, type: Integer, desc: "Filter by GroupDco ID."
          optional :day, type: String, desc: "Filter by day of the week."
        end
        get do
          schedules = GroupDcoSchedule.all
          schedules = schedules.where(group_dco_id: params[:group_dco_id]) if params[:group_dco_id].present?
          schedules = schedules.where(day: params[:day]) if params[:day].present?
          present schedules, with: Api::V1::Entities::GroupDcoScheduleEntity
        end

        # POST /api/v1/group_dco_schedules
        desc "Create a group DCO schedule"
        params do
          use :shared_schedule_params
          requires :group_dco_id, type: Integer, desc: 'ID of the associated GroupDco.'
          requires :day
          requires :start_time
          requires :end_time
        end
        post do
          schedule_params = declared(params, include_missing: false)
          schedule = GroupDcoSchedule.new(schedule_params)

          if schedule.save
            present schedule, with: Api::V1::Entities::GroupDcoScheduleEntity
          else
            error!({ errors: schedule.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/group_dco_schedules/:id
          desc "Return a specific group DCO schedule"
          get do
            schedule = GroupDcoSchedule.find(params[:id])
            present schedule, with: Api::V1::Entities::GroupDcoScheduleEntity
          end

          # PUT /api/v1/group_dco_schedules/:id
          desc "Update a group DCO schedule"
          params do
            use :shared_schedule_params
          end
          put do
            schedule = GroupDcoSchedule.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if schedule.update(update_params)
              present schedule, with: Api::V1::Entities::GroupDcoScheduleEntity
            else
              error!({ errors: schedule.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/group_dco_schedules/:id
          desc "Delete a group DCO schedule"
          delete do
            schedule = GroupDcoSchedule.find(params[:id])
            if schedule.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete group DCO schedule"] }, 500)
            end
          end

        end
      end
    end
  end
end
