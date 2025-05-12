class StripeService
  include Rails.application.routes.url_helpers

  def initialize(order)
    @order = order
  end

  def create_checkout_session
    success_url = payment_success_order_url(@order, host: 'localhost:3001')
    cancel_url = cancel_order_order_url(@order, host: 'localhost:3001')

    Stripe::Checkout::Session.create({
      payment_method_types: ['card'],
      line_items: [
        {
          price_data: {
            currency: 'usd',
            product_data: {
              name: 'Order Payment',
            },
            unit_amount: @order.total_cents,
          },
          quantity: 1,
        },
      ],
      mode: 'payment',
      success_url: success_url,
      cancel_url: cancel_url,
    })
  end
end
