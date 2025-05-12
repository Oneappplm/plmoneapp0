# app/controllers/admin/transaction_logs_controller.rb
class Admin::TransactionLogsController < ApplicationController
  def index
    @transaction_logs = TransactionLog.order(created_at: :desc).paginate(per_page: 10, page: params[:page] || 1)
  end
end
