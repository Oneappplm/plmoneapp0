class VerificationPlatformController < ApplicationController
  before_action :set_hvhs_datum, only: [:show, :edit, :update, :destroy]
		before_action :redirect_to_auto_verify, only: [:index]

  def index
    if params[:page]
      render params[:page]
    else
      @hvhs_data = if params[:search].present?
        HvhsDatum.search(params[:search]).paginate(per_page: 10, page: params[:page] || 1)
      else
        HvhsDatum.paginate(per_page: 10, page: params[:page] || 1)
      end
    end
  end

  def show
    render 'overview'
  end

  protected
  def set_hvhs_datum
    @hvhs_datum = HvhsDatum.find(params[:id])
  end

		def redirect_to_auto_verify
			if current_setting.dcs?
				redirect_to auto_verifies_path and return
			end
		end
end
