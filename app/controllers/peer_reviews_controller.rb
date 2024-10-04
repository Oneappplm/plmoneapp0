class PeerReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_provider, :check_committee_date_presence, only: [:create]
  before_action :set_review, only: [:update, :destroy]

  def create
    peer_review = PeerReview.new(peer_review_params)

    if peer_review.save
      redirect_to work_ticklers_path, notice: 'Peer Review Created Successfully'
    else
      redirect_to work_ticklers_path, alert: 'Failed to Create Peer Review'
    end
  end

  def update
    if @review.update(peer_review_params)
      redirect_to work_ticklers_path, notice: 'Peer Review Updated Successfully'
    else
      redirect_to work_ticklers_path, alert: 'Failed to update peer review'
    end
  end

  def destroy
    if @review.destroy
      redirect_to work_ticklers_path, notice: 'Peer Review Deleted Successfully'
    else
      redirect_to work_ticklers_path, alert: 'Failed to delete peer review'
    end
  end

  private

  def peer_review_params
    params.require(:peer_review).permit(:provider_id, :committee_date, :review_status, :feedback)
  end

  def check_committee_date_presence
    if params[:peer_review][:committee_date].blank?
      redirect_to work_ticklers_path, alert: 'Committee Date is Required'
    end
  end

  def set_provider
    @provider = Provider.find(params[:peer_review][:provider_id])
    redirect_to work_ticklers_path, alert: 'Provider Not Found' unless @provider
  end

  def set_review
    @review = PeerReview.find(params[:id])
    redirect_to work_ticklers_path, alert: 'Peer Review Not Found' unless @review
  end
end
