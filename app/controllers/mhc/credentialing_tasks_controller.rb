class Mhc::CredentialingTasksController < ApplicationController
  def index
    base_scope=EnrollmentProvidersDetail.includes(:assigned_user,:follow_ups,enrollment_provider: :provider)

    unless current_user.super_administrator?
      base_scope = base_scope.where(
        assigned_user_id: current_user.id
      )
    end

    @overdue = base_scope
      .overdue
      .order(:next_follow_up_date)

    @due_today = base_scope
      .due_today
      .order(:next_follow_up_date)

    @upcoming_count = base_scope
      .upcoming
      .count

    @upcoming = base_scope
      .upcoming
      .order(:next_follow_up_date)
      .limit(20)
  end
end
