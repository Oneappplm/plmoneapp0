class MissingFieldSubmissionsController < ApplicationController
  before_action :set_submission, only: [:update]

  def index;end

  def create;end

  def update
    @submission.update_provider_fields
    @submission.completed_by = current_user.id
    @submission.status = "done"
    @submission.save
    render json: {
      'status' => @submission.status
    }
  end

  def destroy;end

  private

  def set_submission
    @submission = ProvidersMissingFieldSubmission.find(params[:id])
  end

  def missing_field_submission_params
    params.require(:provider).permit(:data_key[], :data_value[])
  end

end