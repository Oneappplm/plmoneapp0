class FaqsController < ApplicationController
  def index
    @faqs = Faq.where(visible: true)
  end
end
