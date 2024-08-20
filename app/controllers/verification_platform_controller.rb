class VerificationPlatformController < ApplicationController
  before_action :set_hvhs_datum, only: [:show, :edit, :update, :destroy]
  before_action :set_app_tracker, only: [:edit_application, :update_application]

  def index
    if (params[:practitioner]).present?
      @app_tracker = AppTracker.new(practitioner_id: params[:practitioner])
      @practitioner = Practitioner.find(params[:practitioner])
      @app_trackers = AppTracker.where(practitioner: @practitioner.id)
    end

    if params[:page]
      render params[:page]
    else
      @hvhs_data = if params[:search].present?
        HvhsDatum.search(params[:search]).paginate(per_page: 10, page: params[:page] || 1)
      else
        HvhsDatum.paginate(per_page: 10, page: params[:page] || 1)
      end
      @practitioners = Practitioner.paginate(per_page: 10, page: params[:page] || 1)
    end
  end

  def show
    render 'overview'
  end

  def add_new_application
    @app_tracker = AppTracker.new(app_tracker_params)

    if @app_tracker.save
      redirect_to verification_platform_index_path(page: 'app_tracking', practitioner: params[:app_tracker][:practitioner_id])
    end
  end

  def edit_application
    @practitioner = @app_tracker&.practitioner
  end

  def update_application
    @practitioner = @app_tracker&.practitioner
    if @app_tracker.update(app_tracker_params)
      redirect_to verification_platform_index_path(page: 'app_tracking', practitioner: @app_tracker.practitioner_id), notice: 'Application successfully updated.'
    else
      render :edit_application, alert: 'Error updating application.'
    end
  end


  protected
  def set_hvhs_datum
    @hvhs_datum = HvhsDatum.find(params[:id])
  end

  private 

  def set_app_tracker
    @app_tracker = AppTracker.find(params[:id])
  end

  def app_tracker_params
    params.require(:app_tracker).permit(
      :application_type,
      :application_receipt_date,
      :application_receive_complete_date,
      :verifications_complete_date,
      :file_return_to_client_date,
      :output_file_date,
      :owner,
      :application_submitted_date,
      :practitioner_id,
      :file_status,
      :comments,
      :master_review_list,
      :master_issue_list,
      :expedite,
      :issue,
      :review
    )
  end
end
