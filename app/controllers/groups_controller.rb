class GroupsController < ApplicationController
  # get practice location
  def get_dcos
    enrollment_group = EnrollmentGroup.find_by(id: params[:group_id])
    dcos = enrollment_group.dcos
    arr_dcos = (dcos.blank? ? [] : dcos.pluck(:id, :dco_name))
    # this part will be used for search form in base_url/enrollment-clients since dco_name is being save in Provider table
    if !params[:get_name].blank?
      arr_dcos = (dcos.blank? ? [] : dcos.pluck(:dco_name, :dco_name))
    end
    render json: {
      "practice_locations" => arr_dcos
    }
  end
end