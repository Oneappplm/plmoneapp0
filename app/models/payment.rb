class Payment < ApplicationRecord
  belongs_to :order

  enum status: { pending: "pending", succeeded: "succeeded", failed: "failed" }
  enum payment_method: { card: "card", crypto: "crypto", solana: "solana" }

  validates :amount, numericality: { greater_than: 0, message: "must be greater than zero" }
end
