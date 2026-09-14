class Order < ApplicationRecord
	before_create :generate_payment_memo

  belongs_to :client_organization
  has_many :provider_profiles, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_one :payment, dependent: :destroy

  enum status: { pending: "pending", awaiting_crypto: "awaiting_crypto", paid: "paid", processing: "processing", completed: "completed" }

  enum payment_method: { card: "card", crypto: "crypto", solana: "solana" }

  def calculate_total!
    total_cents = order_items.includes(:verification_product).sum do |item|
      item.verification_product&.price_in_cents.to_i
    end

    update!(total_cents: total_cents)
  end

  def total_amount
	  (total_cents || 0) / 100_000.0
	end

	private

  def generate_payment_memo
    self.payment_memo ||= "order-#{SecureRandom.hex(5)}"
  end
end

