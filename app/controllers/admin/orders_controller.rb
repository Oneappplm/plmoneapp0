class Admin::OrdersController < ApplicationController
  before_action :set_order, only: [:show]

  def index
    @orders = Order.where(status: ['paid', 'pending']).order(created_at: :desc)
  end

  def show
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end
end
