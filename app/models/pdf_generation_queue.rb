class PdfGenerationQueue < ApplicationRecord
  belongs_to :provider_personal_information
  has_many :pdf_queue_items, dependent: :destroy
  has_one :saved_profile, dependent: :destroy

  before_create :generate_queue_number

  enum status: { queued: "queued", processing: "processing", sent: "sent", error: "error", completed: "completed" }

  def generate_queue_number
    self.queue_number = rand(100000..999999).to_s
  end

  def reconcile_status!
    total = pdf_queue_items.count
    return update!(status: "error", message: "No items found") if total == 0

    completed  = pdf_queue_items.where(status: "completed").count
    errors     = pdf_queue_items.where(status: "error").count
    processing = pdf_queue_items.where(status: "processing").count
    queued     = pdf_queue_items.where(status: "queued").count

    if errors > 0
      update!(status: "error", message: "#{errors} item(s) failed")
    elsif completed == total
      # If merge already produced a SavedProfile, mark completed
      if saved_profile.present?
        update!(status: "completed", message: "PDF generated successfully")
      else
        # completed items but merge not run yet
        update!(status: "processing", message: "All items complete, waiting for merge")
      end
    elsif processing > 0
      update!(status: "processing", message: "Processing #{processing}/#{total}")
    else
      update!(status: "queued", message: "Queued #{queued}/#{total}")
    end
  end
end
