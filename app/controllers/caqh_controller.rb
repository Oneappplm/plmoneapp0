class CaqhController < ApplicationController
  protect_from_forgery with: :null_session

  def show
  end

  def upload
    Caqh::ImportService.call(params)
  end
end
