class VerificationPlatformController < ApplicationController
  before_action :set_hvhs_datum, only: [:show, :edit, :update, :destroy]

  def index
    @q = TblIi.ransack(params[:q])
    
    if params[:page]
      render params[:page]
    else
      @hvhs_data = if params[:search].present?
        TblIi.search(params[:search]).paginate(per_page: 10, page: params[:page] || 1)
      else
        @q.result.paginate(per_page: 10, page: params[:page] || 1)
      end
    end
  end

  def show
    render 'overview'
  end

  protected
  def set_hvhs_datum
    @hvhs_datum = TblIi.find(params[:id])
  end
end
