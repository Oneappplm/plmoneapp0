module Api
  module V1
    class AddSchedules < Grape::API

      helpers do
        params :shared_add_schedule_params do
          optional :group_name, type: String, desc: 'Name of the group for the schedule.'
          optional :description, type: String, desc: 'Description of the schedule.'
          optional :add_members, type: Array[String], desc: 'List of added members.'
        end
      end

      resource :add_schedules do

        # GET /api/v1/add_schedules
        desc "Return a list of schedules"
        params do
          optional :group_name, type: String, desc: "Filter by group name."
        end
        get do
          schedules = AddSchedule.all
          schedules = schedules.where(group_name: params[:group_name]) if params[:group_name].present?
          present schedules, with: Api::V1::Entities::AddScheduleEntity
        end

        # POST /api/v1/add_schedules
        desc "Create a schedule"
        params do
          use :shared_add_schedule_params
          requires :group_name
        end
        post do
          schedule_params = declared(params, include_missing: false)
          schedule = AddSchedule.new(schedule_params)

          if schedule.save
            present schedule, with: Api::V1::Entities::AddScheduleEntity
          else
            error!({ errors: schedule.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/add_schedules/:id
          desc "Return a specific schedule"
          get do
            schedule = AddSchedule.find(params[:id])
            present schedule, with: Api::V1::Entities::AddScheduleEntity
          end

          # PUT /api/v1/add_schedules/:id
          desc "Update a schedule"
          params do
            use :shared_add_schedule_params
          end
          put do
            schedule = AddSchedule.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if schedule.update(update_params)
              present schedule, with: Api::V1::Entities::AddScheduleEntity
            else
              error!({ errors: schedule.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/add_schedules/:id
          desc "Delete a schedule"
          delete do
            schedule = AddSchedule.find(params[:id])
            if schedule.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete schedule"] }, 500)
            end
          end

        end
      end
    end
  end
end
