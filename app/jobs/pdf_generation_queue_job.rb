# app/jobs/pdf_generation_queue_job.rb
class PdfGenerationQueueJob < ApplicationJob
  queue_as :pdf_generation

  def perform(queue_id)
    queue = PdfGenerationQueue.unscoped.find(queue_id)
    provider = ProviderPersonalInformation.unscoped.find(queue.provider_personal_information_id)
    user = User.find(queue.user_id || 1)

    queue.with_lock do
      queue.update!(
        status: "processing",
        message: "Items queued for processing",
        merge_enqueued: false,
        queued_date: queue.queued_date || Time.current
      )

      # Enqueue only items that aren't completed yet
      queue.pdf_queue_items.where.not(status: "completed").find_each do |item|
        # Backward-compatible: PdfQueueItemJob supports 1 or 3 args
        PdfQueueItemJob.perform_later(item.id, provider.id, user.id)
      end
    end
  rescue => e
    Rails.logger.error "❌ [QUEUE JOB] FAILED queue=#{queue_id} #{e.class} #{e.message}"
    Rails.logger.error e.backtrace.first(15).join("\n")
    PdfGenerationQueue.unscoped.where(id: queue_id).update_all(status: "error", message: "#{e.class}: #{e.message}")
    raise e
  end
end
