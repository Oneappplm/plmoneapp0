class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :verification_product

  def product_price
    verification_product.price
  end
end
