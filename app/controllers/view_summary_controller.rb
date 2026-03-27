class ViewSummaryController < ApplicationController
  before_action :set_current_provider_source, only: [:index, :download_pdf]

  def index
    if params[:page].present?
      render params[:page].to_s
    else
      render :index
    end
  end

  # for download the view summary into the pdf
  def download_pdf
    respond_to do |format|
      format.pdf do
        render pdf: "view_summary",
               template: "view_summary/download_pdf",
               layout: "pdf", 
               formats: [:html],
               disposition: "attachment"
      end
    end
  end

  private

  def set_current_provider_source
    @current_provider_source = ProviderSource.includes(:data).where(created_by_user: current_user.id).current
  end
end
