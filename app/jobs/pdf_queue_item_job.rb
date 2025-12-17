# app/jobs/pdf_queue_item_job.rb
require "aws-sdk-s3"
require "open-uri"
require "uri"
require "fileutils"
require "wicked_pdf"

class PdfQueueItemJob < ApplicationJob
  queue_as :pdf_generation

  # Support BOTH old + new enqueued args:
  # 1) perform(item_id)
  # 2) perform(item_id, provider_id, user_id)
  def perform(item_id, provider_id = nil, user_id = nil)
    item = PdfQueueItem.find(item_id)
    queue = item.pdf_generation_queue

    provider_id ||= queue.provider_personal_information_id
    user_id     ||= queue.user_id || 1

    provider = ProviderPersonalInformation.find(provider_id)
    user     = User.find(user_id)

    Rails.logger.info "🧾 ITEM start id=#{item.id} queue=#{queue.id}"

    # Mark item as processing if your enum allows it.
    # If your model only has queued/completed/error, comment this out.
    safe_update_item(item, status: "processing", message: "Processing started") if status_allowed?(item, "processing")

    if item.file_name == "Verified Profile" || item.file_path.to_s == "verified_profile"
      pdf_path = render_verified_profile_pdf(provider, user)
      safe_update_item(item, status: "completed", file_path: pdf_path, message: "Verified Profile PDF generated")
      Rails.logger.info "✅ ITEM verified profile done id=#{item.id} path=#{pdf_path}"
    else
      handle_non_verified_item(item)
    end

    enqueue_merge_if_ready(queue, provider, user)
  rescue => e
    Rails.logger.error "❌ ITEM FAILED id=#{item_id} #{e.class} #{e.message}"
    Rails.logger.error e.backtrace.first(15).join("\n")
    item.update(status: "error", message: e.message) if item&.persisted?
    raise e
  end

  private

  # -------- Helpers --------

  def enqueue_merge_if_ready(queue, provider, user)
    queue.with_lock do
      remaining = queue.pdf_queue_items.where.not(status: "completed").count
      if remaining.zero? && !queue.merge_enqueued?
        queue.update!(merge_enqueued: true)
        PdfQueueMergeJob.perform_later(queue.id, provider.id, user.id)
        Rails.logger.info "🚀 All items completed. Enqueued merge for queue=#{queue.id}"
      else
        Rails.logger.info "⏳ Merge not ready queue=#{queue.id} remaining=#{remaining} merge_enqueued=#{queue.merge_enqueued?}"
      end
    end
  end

  def handle_non_verified_item(item)
    file_path_value = item.file_path.to_s.strip

    if file_path_value.blank?
      safe_update_item(item, status: "error", message: "File path blank")
      Rails.logger.warn "⚠️ ITEM blank file_path id=#{item.id}"
      return
    end

    if remote_url?(file_path_value)
      # OPTIONAL: skip HEAD checks for speed; merge job will download anyway.
      safe_update_item(item, status: "completed", message: "Remote file queued for merge")
      Rails.logger.info "🌐 ITEM remote accepted id=#{item.id}"
    else
      local_path = Rails.root.join("public", file_path_value.sub(%r{^/}, ""))
      if File.exist?(local_path)
        safe_update_item(item, status: "completed", message: "Local file ready for merge")
        Rails.logger.info "📁 ITEM local exists id=#{item.id} path=#{local_path}"
      else
        safe_update_item(item, status: "error", message: "File missing: #{local_path}")
        Rails.logger.warn "⚠️ ITEM missing local id=#{item.id} path=#{local_path}"
      end
    end
  end

  def remote_url?(str)
    str =~ /\Ahttps?:\/\//i
  end

  def safe_update_item(item, attrs)
    # avoids enum errors if status value isn't allowed
    if attrs[:status] && !status_allowed?(item, attrs[:status])
      attrs = attrs.except(:status)
    end
    item.update!(attrs)
  end

  def status_allowed?(record, value)
    # works for string status too; for enum it’s best
    return true unless record.class.respond_to?(:statuses)
    record.class.statuses.key?(value)
  rescue
    true
  end

  # -------- Verified profile PDF --------

  def render_verified_profile_pdf(provider, user)
    pdf_dir = Rails.root.join("public/generated_pdfs")
    FileUtils.mkdir_p(pdf_dir)

    filename = "#{provider.caqh_provider_attest_id}_verified_profile_#{Time.current.strftime('%Y%m%d%H%M%S')}.pdf"
    pdf_path = pdf_dir.join(filename)

    html_content = ApplicationController.render(
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

    pdf_binary = WickedPdf.new.pdf_from_string(
      html_content,
      disable_javascript: true,
      enable_local_file_access: true,
      dpi: 96,
      zoom: 1.0
    )

    File.open(pdf_path, "wb") { |f| f.write(pdf_binary) }

    # IMPORTANT: return a PUBLIC URL path (not filesystem path)
    "/generated_pdfs/#{filename}"
  end
end
