class VerificationPlatformController < ApplicationController
  before_action :set_hvhs_datum, only: [:show, :edit, :update, :destroy]

  def index
    if params[:page]
      render params[:page]
    else
      @hvhs_data = if params[:search].present?
        HvhsDatum.search(params[:search]).paginate(per_page: 10, page: params[:page] || 1)
      else
        HvhsDatum.paginate(per_page: 10, page: params[:page] || 1)
      end
      @practitioners = Practitioner.paginate(per_page: 10, page: params[:page] || 1)
    end
  end

  def show
    render 'overview'
  end

  protected
  def set_hvhs_datum
    @hvhs_datum = HvhsDatum.find(params[:id])
  end
end
