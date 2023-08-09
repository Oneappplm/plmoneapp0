class EnrollmentGroupsController < ApplicationController
  before_action :get_enrollment_group, only: [:show, :locations, :documents]

  def show
  end


  private

  def get_enrollment_group
    @enrollment_group = EnrollmentGroup.find(params[:id] || params[:enrollment_group_id])
  end
end