class ApiDocsController < ApplicationController
  def swagger_ui
    render layout: false
  end
end
