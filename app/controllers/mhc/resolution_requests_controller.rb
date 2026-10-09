class Mhc::ResolutionRequestsController < ApplicationController
  before_action :authorize_resolution_manager!
  before_action :set_follow_up, only: [:approve, :reject]

  def index
    @resolution_requests=FollowUp.includes(:user,:enrollment_providers_detail,enrollment_provider: :provider).where(resolution_status: :awaiting_manager_approval).order(created_at: :asc)
  end

  def approve
    ActiveRecord::Base.transaction do
      @follow_up.update!(resolution_status: :approved,approved_by: current_user,approved_at: Time.current)

      if @follow_up.enrollment_providers_detail.present?
        @follow_up.enrollment_providers_detail.update!(follow_up_status: :resolved,next_follow_up_date: nil)
      end

      reject_other_pending_requests
    end

    redirect_to mhc_resolution_requests_path,notice: "Resolution request approved successfully."
  end

  def reject
    ActiveRecord::Base.transaction do
      @follow_up.update!(resolution_status: :rejected,approved_by: current_user,approved_at: Time.current)

      if @follow_up.enrollment_providers_detail.present?
        @follow_up.enrollment_providers_detail.update!(follow_up_status: :pending,next_follow_up_date: Date.current)
      end
    end

    redirect_to mhc_resolution_requests_path,notice: "Resolution request rejected."
  end

  private

  def authorize_resolution_manager!
    return if current_user&.user_role.in?(%w[super_administrator administrator])

    redirect_to mhc_credentialing_tasks_path,alert: "You are not authorized to review resolution requests."
  end

  def set_follow_up
    @follow_up=FollowUp.find(params[:id])
  end

  def reject_other_pending_requests
    return unless @follow_up.enrollment_providers_detail_id.present?

    FollowUp.where(enrollment_providers_detail_id: @follow_up.enrollment_providers_detail_id,resolution_status: :awaiting_manager_approval).where.not(id: @follow_up.id).update_all(resolution_status: FollowUp.resolution_statuses[:rejected],updated_at: Time.current)
  end
end
