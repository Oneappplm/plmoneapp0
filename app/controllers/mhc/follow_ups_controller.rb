class Mhc::FollowUpsController < ApplicationController
  before_action :set_enrollment_provider
  before_action :set_enrollment_detail

  def index
    @follow_ups = @enrollment_detail.follow_ups.order(created_at: :desc)
  end

  def new
    if @enrollment_detail.resolved?
      redirect_to mhc_credentialing_tasks_path, alert: "This payer enrollment has already been resolved."
      return
    end

    if @enrollment_detail.resolution_requested?
      redirect_to mhc_credentialing_tasks_path, alert: "A resolution request for this payer enrollment is already awaiting manager approval."
      return
    end

    load_follow_up_page_data

    current_next_date=@enrollment_detail.next_follow_up_date
    next_follow_up_date=current_next_date if current_next_date.present? && current_next_date >= Date.current

    @follow_up=@enrollment_detail.follow_ups.new(enrollment_provider:@enrollment_provider,next_follow_up_date:next_follow_up_date)
  end

  def create
    if @enrollment_detail.resolved?
      redirect_to mhc_credentialing_tasks_path, alert: "This payer enrollment has already been resolved."
      return
    end

    if @enrollment_detail.resolution_requested?
      redirect_to mhc_credentialing_tasks_path, alert: "A resolution request for this payer enrollment is already awaiting manager approval."
      return
    end

    @follow_up = @enrollment_detail.follow_ups.new(follow_up_params)
    @follow_up.enrollment_provider = @enrollment_provider
    @follow_up.user = current_user
    @follow_up.followed_up_at = Time.current

    ActiveRecord::Base.transaction do
      if @follow_up.resolution_requested?
        prevent_duplicate_resolution_request!

        @follow_up.resolution_status = :awaiting_manager_approval
        @enrollment_detail.follow_up_status = :resolution_requested
        @enrollment_detail.next_follow_up_date = nil
      else
        @follow_up.resolution_status = :open
        @enrollment_detail.follow_up_status = :pending
        @enrollment_detail.next_follow_up_date = @follow_up.next_follow_up_date
      end

      @follow_up.save!
      @enrollment_detail.save!
    end

    redirect_to mhc_credentialing_tasks_path, notice: "Follow-up saved successfully."
  rescue ActiveRecord::RecordInvalid
    load_follow_up_page_data
    render :new, status: :unprocessable_entity
  end

  private

  def set_enrollment_provider
    @enrollment_provider = EnrollmentProvider.find(params[:enrollment_provider_id])
  end

  def set_enrollment_detail
    @enrollment_detail = @enrollment_provider.details.find(params[:detail_id])
  end

  def load_follow_up_page_data
    @follow_up_history = @enrollment_detail.follow_ups.order(followed_up_at: :desc)
    @last_follow_up_date = @enrollment_detail.follow_ups.where.not(followed_up_at: nil).order(followed_up_at: :desc).limit(1).pick(:followed_up_at)
  end

  def prevent_duplicate_resolution_request!
    return unless @enrollment_detail.follow_ups.where(resolution_status: :awaiting_manager_approval).exists?

    @follow_up.errors.add(:base, "A resolution request is already awaiting manager approval.")
    raise ActiveRecord::RecordInvalid.new(@follow_up)
  end

  def follow_up_params
    params.require(:follow_up).permit(:notes, :next_follow_up_date, :resolution_requested)
  end
end
