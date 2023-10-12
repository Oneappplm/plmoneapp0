class AltEnrollmentGroupsController < ApplicationController
  before_action :get_enrollment_group, only: [:show, :locations, :documents, :enrollments, :providers]
  before_action :get_enroll_groups, only: [:enrollments]
  before_action :get_enrollment_group_providers, only: [:providers]

  def show; end

  def documents; end

  def enrollments; end

  def providers; end

  private

  def get_enrollment_group
    @enrollment_group = EnrollmentGroup.find(params[:id] || params[:alt_enrollment_group_id])
  end

  def get_enroll_groups
    # get's enroll group to get the enroll_group.details where most important information are.
    @enroll_groups = EnrollGroup.where(group_id: @enrollment_group.id)
  end

  def get_enrollment_group_providers
    @providers = @enrollment_group.providers
    @providers = @providers.paginate(per_page: 50, page: params[:page] || 1)
  end
end