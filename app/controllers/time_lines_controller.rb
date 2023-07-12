class TimeLinesController < ApplicationController
  before_action :set_timeline, only: [:edit, :update, :destroy]

  def create
    @time_line = ProvidersTimeLine.new(time_line_params)

    if @time_line.save
      redirect_to request.referrer
    end
  end

  def update
    if @timeline.update(time_line_params)
      redirect_to request.referrer
    end
  end

  def destroy
    if @timeline.update_attribute('status','deleted')
      redirect_to request.referrer
    end
  end

  def show
  end

  def edit
  end

  private

  def time_line_params
    params.require(:providers_time_line).permit(:title, :due_date, :notes, :provider_id, :status)
  end

  def set_timeline
    @timeline = ProvidersTimeLine.find(params[:id])
  end
end