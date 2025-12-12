# app/services/pdf_generation_service.rb
require 'fileutils'

class PdfGenerationService
  attr_reader :queue, :provider, :user

  def initialize(queue, provider, user)
    @queue    = queue
    @provider = provider
    @user     = user
  end

  def process_queue!
    Rails.logger.info "Starting PDF generation for queue=#{queue.id} provider=#{provider.id}"

    queue.update!(
      status: 'processing',
      message: 'Enqueued PDF generation items.'
    )

    enqueue_items!

  rescue => e
    Rails.logger.error "PdfGenerationService FAILED: #{e.class} #{e.message}\n#{e.backtrace.first(10).join("\n")}"
    queue.update!(status: 'error', message: "#{e.class}: #{e.message}")
  end

  private

  def enqueue_items!
    queue.pdf_queue_items.find_each do |item|
      PdfQueueItemJob.perform_later(item.id, provider.id, user.id)
    end
  end
end
