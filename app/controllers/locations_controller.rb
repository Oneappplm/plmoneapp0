class LocationsController < ApplicationController
  before_action :get_enrollment_group, only: [:index, :show]
  before_action :set_location, only: [:show]

  def show
  end

  private

  def get_enrollment_group
    @enrollment_group = EnrollmentGroup.find(params[:id] || params[:alt_enrollment_group_id])
  end

  def set_location
    @location = GroupDco.find(params[:id])
  end
end