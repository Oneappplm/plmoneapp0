class OrdersController < ApplicationController
  before_action :set_client_org
  before_action :set_order, only: [:show, :pay, :confirm_payment]

  def index
    @orders = @client_org.orders.includes(:payment)
  end

  def new
    @products = VerificationProduct.order(created_at: :desc).paginate(per_page: 10, page: params[:page] || 1)
  end

  def create
    @client_org = current_client_organization

    unless @client_org&.persisted?
      raise "No client organization present!"
    end

    order = @client_org.orders.create!(order_params)
    # order.update(payment_memo: "ORDER-#{order.id}")
    order.update!(payment_memo: SecureRandom.hex(6)) unless order.payment_memo.present?

    params[:product_ids].each do |pid|
      order.order_items.create!(verification_product_id: pid)
    end

    order.calculate_total!

    redirect_to upload_providers_order_path(order)
  end

  def show
    respond_to do |format|
      format.html # renders show.html.erb by default
      format.json { render json: @order }
    end
  end

  def upload_providers
    @order = @client_org.orders.find(params[:id])
  end

  def submit_providers
    @order = @client_org.orders.find(params[:id])
    if params[:csv_file].present?
      CsvUploadService.new(@order, params[:csv_file]).call
    else
      @order.provider_profiles.create!(provider_params)
    end
    redirect_to checkout_order_path(@order)
  end

  def checkout
    @order = @client_org.orders.find(params[:id])
    @order.calculate_total!

    total_cents = (@order.total_amount * 100).to_i

    # if total_cents < 50
    #   raise "Order total is not set"
    # end

    # @checkout_session = Stripe::Checkout::Session.create(
    #   payment_method_types: ['card'],
    #   line_items: [{
    #     price_data: {
    #       currency: 'usd',
    #       product_data: {
    #         name: "Verification Order"
    #       },
    #       unit_amount: total_cents
    #     },
    #     quantity: 1
    #   }],
    #   mode: 'payment',
    #   success_url: payment_success_order_url(@order),
    #   cancel_url: cancel_order_order_url(@order)
    # )
  end


  def payment_success
    @order = @client_org.orders.find(params[:id])
    @order.reload

    respond_to do |format|
      format.html do
        redirect_to @order
      end
      format.json do
        render json: {
          order_id: @order.id,
          status: @order.status,
          paid: @order.status == "paid"
        }
      end
    end
  end


  def cancel_order
    @order = @client_org.orders.find(params[:id])
    redirect_to @order, alert: 'Payment was canceled.'
  end

  def confirm_crypto_payment
    order = current_client_organization.orders.find(params[:id])

    # Enqueue payment verification job if order still pending
    if order.status == "pending"
      SolanaPaymentVerifierJob.perform_later(order.id)
    end

    # Reload order to get updated status (optional if job is very fast)
    order.reload

    payment_confirmed = (order.status == "paid")

    respond_to do |format|
      format.json do
        render json: {
          order_id: order.id,
          status: order.status,
          payment_confirmed: payment_confirmed,
          message: payment_confirmed ? "Payment received! Status: Paid" : "Still waiting for confirmation. Try again later."
        }
      end
    end
  end

  private

  def set_client_org
    @client_org = current_client_organization
  end

  def set_order
    @order = @client_org.orders.find_by(id: params[:id])
  end

  def order_params
    params.permit(:id)
  end

  def provider_params
    params.require(:provider_profile).permit(:first_name, :last_name, :npi_number, :license_number, :state)
  end
end
