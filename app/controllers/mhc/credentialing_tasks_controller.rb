class Mhc::CredentialingTasksController < ApplicationController
	def index
    @overdue = EnrollmentProvider
      .includes(:provider)
      .overdue
      .order(:next_follow_up_date)

    @due_today = EnrollmentProvider
      .includes(:provider)
      .due_today
      .order(:next_follow_up_date)

    @upcoming = EnrollmentProvider
      .includes(:provider)
      .upcoming
      .order(:next_follow_up_date)
      .limit(20)
  end
end
