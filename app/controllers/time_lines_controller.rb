class TimeLinesController < ApplicationController

  def create
    @time_line = ProvidersTimeLine.new(time_line_params)

    if @time_line.save
      redirect_to request.referrer
    end
  end

  def update
  end

  def destroy
  end

  private

  def time_line_params
    params.require(:providers_time_line).permit(:title, :due_date, :notes, :provider_id, :status)
  end
end