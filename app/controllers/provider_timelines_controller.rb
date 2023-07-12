class ProviderTimelinesController < ApplicationController

  def create
    timeline = ProviderTimeline.new(comment_params)

    if timeline.save
      redirect_to request.referrer
    end
  end

  private

  def timeline_params
    params.require(:provider_timeline).permit(:title, :due_date, :notes, :status, :provider_id)
  end

end