class OfficeManagerController < ApplicationController

  def index
    if params[:page].present?
      render params[:page]
    end
  end

end