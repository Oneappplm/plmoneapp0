class VerificationProduct < ApplicationRecord
  has_many :order_items
  has_many :verification_tasks

  enum status: { active: 0, inactive: 1 }

  validates :name, :price, presence: true

  def price_in_cents
    (price.to_f * 100_000).round
  end
end
