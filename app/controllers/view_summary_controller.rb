class ViewSummaryController < ApplicationController
	before_action :set_current_provider_source, only: [:index]
  def index
    if params[:page].present?
      render params[:page].to_s
    end
  end

  private
  def set_current_provider_source
    @current_provider_source = ProviderSource.includes(:data).current
  end
end