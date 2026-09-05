class Mhc::FollowUpsController < ApplicationController
  before_action :set_enrollment_provider

  def index
    @follow_ups = @enrollment_provider.follow_ups.order(created_at: :desc)
  end

  def new
	  @follow_up = @enrollment_provider.follow_ups.new(
	    next_follow_up_date: @enrollment_provider.next_follow_up_date
	  )

	  @follow_up_history =
	    @enrollment_provider
	      .follow_ups
	      .order(followed_up_at: :desc)
	end

  def create
    @follow_up = @enrollment_provider.follow_ups.new(follow_up_params)

    @follow_up.user = current_user
    @follow_up.followed_up_at = Time.current

    ActiveRecord::Base.transaction do
      if @follow_up.resolution_requested?
        @follow_up.resolution_status = :awaiting_manager_approval

        @enrollment_provider.follow_up_status =
          :resolution_requested
      else
        @follow_up.resolution_status = :open

        @enrollment_provider.follow_up_status = :pending

        @enrollment_provider.next_follow_up_date =
          @follow_up.next_follow_up_date
      end

      @follow_up.save!
      @enrollment_provider.save!
    end

    redirect_to mhc_credentialing_tasks_path,
                notice: "Follow-up saved successfully."

  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  private

  def set_enrollment_provider
    @enrollment_provider =
      EnrollmentProvider.find(params[:enrollment_provider_id])
  end

  def follow_up_params
    params.require(:follow_up).permit(
      :notes,
      :next_follow_up_date,
      :resolution_requested
    )
  end
end