class PdfQueueItem < ApplicationRecord
  belongs_to :pdf_generation_queue

  enum status: { queued: "queued", sent: "sent", completed: "completed", error: "error" }
end
