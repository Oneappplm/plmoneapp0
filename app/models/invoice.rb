class Invoice < ApplicationRecord
  belongs_to :doctor
  belongs_to :patient
  belongs_to :appointment, optional: true

  enum status: { 
    unpaid: 'Unpaid', 
    paid: 'Paid',
    partially_paid: 'Partially Paid',
    refunded: 'Refunded' 
  }

  # validates :service_name, :payment_method, presence: true
  before_validation :generate_invoice_number, on: :create
  before_save :calculate_total

  def generate_invoice_number
    self.invoice_number ||= "Inv-#{SecureRandom.hex(4).upcase}" 
  end

  def calculate_total
    base = amount.to_f
    disc = discount.to_f
    tax_amt = tax.to_f

    self.total = (base - disc) + tax_amt

    # Example conversion: 1 USD = 10 MEDV tokens
    conversion_rate = 10
    self.medv_token_amount = total.to_f * conversion_rate
  end
end
