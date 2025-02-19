class Admin::FaqsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin

  def index
    @faqs = Faq.all
  end

  def new
    @faq = Faq.new
  end

  def create
    @faq = Faq.new(faq_params)
    if @faq.save
      redirect_to admin_faqs_path, notice: 'FAQ added successfully.'
    else
      render :new
    end
  end

  def edit
    @faq = Faq.find(params[:id])
  end

  def update
    @faq = Faq.find(params[:id])
    if @faq.update(faq_params)
      redirect_to admin_faqs_path, notice: 'FAQ updated successfully.'
    else
      render :edit
    end
  end

  def destroy
    @faq = Faq.find(params[:id])
    @faq.destroy
    redirect_to admin_faqs_path, notice: 'FAQ deleted successfully.'
  end

  private

  def faq_params
    params.require(:faq).permit(:question, :answer, :visible)
  end

  def authorize_admin
    unless current_user.user_role.in?(%w[super_administrator admin])
      redirect_to root_path, alert: 'You are not authorized'
    end
  end
end
