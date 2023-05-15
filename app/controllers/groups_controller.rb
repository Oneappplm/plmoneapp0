class GroupsController < ApplicationController
  # get practice location
  def get_dcos
    enrollment_group = EnrollmentGroup.find_by(id: params[:group_id])
    dcos ||= enrollment_group.dcos
    arr_dcos ||= (dcos.blank? ? [] : dcos.pluck(:dco_name, :dco_name))

    render json: {
      "practice_locations" => arr_dcos
    }
  end
end