# app/jobs/pdf_generation_queue_job.rb
class PdfGenerationQueueJob < ApplicationJob
  queue_as :pdf_generation

  def perform(queue_id)
    queue = PdfGenerationQueue.find(queue_id)
    provider = ProviderPersonalInformation.find(queue.provider_personal_information_id)
    user = User.find(queue.user_id || 1)

    queue.update!(status: "processing", message: "Processing started")

    queue.pdf_queue_items.where(status: "queued").find_each do |item|
      PdfQueueItemJob.perform_later(item.id, provider.id, user.id)
    end
  end
end
