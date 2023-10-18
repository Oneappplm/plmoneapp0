class ManageToolsController < ApplicationController

  def call_schedule_group_maintenance
   @add_schedule = AddSchedule.new
   @add_schedules = AddSchedule.paginate(page: params[:page])
  end

  def creation_of_schedule 
    @add_schedule = AddSchedule.new(add_schedule_params) 
    if @add_schedule.save
      redirect_to call_schedule_group_maintenance_manage_tools_path
    else 
      redirect_to manage_clients_path
    end
  end

  private
  def add_schedule_params
    params.require(:add_schedule).permit(:group_name, :description, add_members:[])
  end
end
