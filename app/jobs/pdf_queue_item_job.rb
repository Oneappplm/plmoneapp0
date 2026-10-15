# app/jobs/pdf_queue_item_job.rb
require "aws-sdk-s3"
require "open-uri"
require "uri"
require "fileutils"
require "wicked_pdf"

class PdfQueueItemJob < ApplicationJob
  queue_as :pdf_generation

  # Supports:
  # perform(item_id)
  # perform(item_id, provider_id, user_id)
  def perform(item_id, provider_id = nil, user_id = nil)
    item  = PdfQueueItem.find(item_id)
    queue = item.pdf_generation_queue

    provider_id ||= queue.provider_personal_information_id
    user_id     ||= queue.user_id || 1

    provider = ProviderPersonalInformation.find(provider_id)
    user     = User.find(user_id)

    Rails.logger.info "🧾 [ITEM] start id=#{item.id} queue=#{queue.id}"

    mark_processing(item)

    if verified_profile_item?(item)
      pdf_path = generate_verified_profile(provider, user)
      safe_update_item(item,
        status:  "completed",
        file_path: pdf_path,
        message: "Verified Profile PDF generated"
      )
      Rails.logger.info "✅ [ITEM] verified profile done id=#{item.id}"
    else
      handle_non_verified_item(item)
    end

    enqueue_merge_if_ready(queue, provider, user)
  rescue => e
    Rails.logger.error "❌ [ITEM FAILED] id=#{item_id} #{e.class}: #{e.message}"
    Rails.logger.error e.backtrace.first(10).join("\n")
    item.update(status: "error", message: e.message) if item&.persisted?
    raise e
  end

  private

  # ----------------------------------------------------
  # Helpers
  # ----------------------------------------------------

  def verified_profile_item?(item)
    item.file_name == "Verified Profile" || item.file_path.to_s == "verified_profile"
  end

   def mark_processing(item)
    return unless item.queued? || item.sent?
    safe_update_item(item, status: "processing", message: "Processing started")
  end

  def enqueue_merge_if_ready(queue, provider, user)
    queue.with_lock do
      total     = queue.pdf_queue_items.count
      completed = queue.pdf_queue_items.completed.count
      errors    = queue.pdf_queue_items.error.count
      queued    = queue.pdf_queue_items.queued.count
      processing = queue.pdf_queue_items.processing.count

      Rails.logger.info "🔎 [QUEUE] id=#{queue.id} total=#{total} completed=#{completed} processing=#{processing} queued=#{queued} errors=#{errors} merge_enqueued=#{queue.merge_enqueued?}"

      # If any item failed, mark queue error and STOP.
      if errors > 0
        queue.update!(
          status: "error",
          message: "#{errors} item(s) failed. Check Sidekiq Failed tab/logs."
        )
        return
      end

      # All items completed -> enqueue merge once
      if total > 0 && completed == total && !queue.merge_enqueued?
        queue.update!(merge_enqueued: true, status: "processing", message: "Merging PDFs...")
        PdfQueueMergeJob.perform_later(queue.id, provider.id, user.id)
        Rails.logger.info "🚀 [MERGE] enqueued queue=#{queue.id}"
      end
    end
  end

  # ----------------------------------------------------
  # Non-verified files
  # ----------------------------------------------------

  def handle_non_verified_item(item)
    path = item.file_path.to_s.strip

    if path.blank?
      safe_update_item(item, status: "error", message: "File path blank")
      return
    end

    if remote_url?(path)
      safe_update_item(item, status: "completed", message: "Remote file accepted")
    else
      local = Rails.root.join("public", path.sub(%r{^/}, ""))

      if File.exist?(local)
        safe_update_item(item, status: "completed", message: "Local file ready")
      else
        safe_update_item(item, status: "error", message: "Missing file: #{local}")
      end
    end
  end

  def remote_url?(str)
    str.match?(/\Ahttps?:\/\//i)
  end

  # ----------------------------------------------------
  # Status safety
  # ----------------------------------------------------

  def safe_update_item(item, attrs)
    if attrs[:status] && !status_allowed?(item, attrs[:status])
      attrs = attrs.except(:status)
    end
    item.update!(attrs)
  end

  def status_allowed?(record, value)
    return true unless record.class.respond_to?(:statuses)
    record.class.statuses.key?(value)
  rescue
    true
  end

  # ----------------------------------------------------
  # Verified Profile PDF (CACHED + SAFE)
  # ----------------------------------------------------

  def generate_verified_profile(provider, user)
    cache_key = "verified_profile:v1:provider=#{provider.id}:user=#{user.id}:updated=#{provider.updated_at.to_i}"

    pdf_path = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
      render_verified_profile_pdf(provider, user)
    end

    disk_path = Rails.root.join("public", pdf_path.sub(%r{^/}, ""))

    unless File.exist?(disk_path)
      Rails.cache.delete(cache_key)
      pdf_path = render_verified_profile_pdf(provider, user)
    end

    pdf_path
  end

  def render_verified_profile_pdf(provider, user)
    pdf_dir = Rails.root.join("public/generated_pdfs")
    FileUtils.mkdir_p(pdf_dir)

    filename = "#{provider.caqh_provider_attest_id}_verified_profile_#{Time.current.strftime('%Y%m%d%H%M%S')}.pdf"
    disk_path = pdf_dir.join(filename)

    html = ApplicationController.render(
      template: "mhc/verification_platform/verified_profile_pdf",
      layout: "pdf",
      locals: {
        provider_personal_information: provider,
        user: user,
        oig_details: provider.rva_informations.where(tab: "OIG", status: "completed").where.not(source_date: nil),
        npdb_details: provider.rva_informations.where(tab: "NPDB"),
        grouped_disclosures: provider.provider_disclosures
          .where(disclosure_answer_flag: true)
          .where.not(disclosure_explanation: [nil, ""])
          .group_by do |d|
            QUESTIONS_DISCLOSURE.find { |_h, qs| qs.include?(d.disclosure_question_disclosure_summary) }&.first
          end
      }
    )

    pdf = WickedPdf.new.pdf_from_string(
      html,
      enable_local_file_access: true,
      disable_javascript: true,
      dpi: 96,
      zoom: 1.0
    )

    File.binwrite(disk_path, pdf)

    "/generated_pdfs/#{filename}"
  end
end
