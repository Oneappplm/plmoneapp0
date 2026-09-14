class Mhc::StatesController < ApplicationController
	before_action :set_state, only: %i[edit update]

  def index
    @states = State.order(:name)

    if params[:query].present?
      q = params[:query].strip
      @states = @states.where(
        "states.name ILIKE :q OR states.alpha_code ILIKE :q",
        q: "%#{q}%"
      )
    end

    @states = @states.paginate(
      per_page: 10,
      page: params[:page] || 1
    )
  end

  def edit
  end

  def update
    old_url = @state.license_search_url

    if @state.update(state_params)
      if old_url != @state.license_search_url
        @state.license_url_histories.create!(
          old_url: old_url,
          new_url: @state.license_search_url,
          changed_at: Time.current
        )
      end
      redirect_to mhc_states_path, notice: "State License URL updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_state
    @state = State.includes(:license_url_histories).find(params[:id])
  end

  def state_params
    params.require(:state).permit(:license_search_url)
  end
end
