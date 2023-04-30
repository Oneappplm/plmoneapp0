class ViewSummaryController < ApplicationController

  def index
    if params[:page].present?
      render params[:page].to_s
    end
  end

end