class PdfGenerationQueue < ApplicationRecord
  belongs_to :provider_personal_information
  has_many :pdf_queue_items, dependent: :destroy
  has_one :saved_profile, dependent: :destroy

  before_create :generate_queue_number

  enum status: { queued: "queued", sent: "sent", error: "error", completed: "completed" }

  def generate_queue_number
    self.queue_number = rand(100000..999999).to_s
  end
end
