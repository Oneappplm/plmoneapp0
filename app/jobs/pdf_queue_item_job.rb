require "aws-sdk-s3"
require "open-uri"
require "uri"
require "fileutils"
require "wicked_pdf"

class PdfQueueItemJob < ApplicationJob
  queue_as :pdf_generation

    # ✅ Backward compatible:
  # - old jobs: perform(item_id, provider_id, user_id)
  # - new jobs: perform(item_id)
  def perform(item_id, provider_id = nil, user_id = nil)
    item = PdfQueueItem.find(item_id)
    queue = item.pdf_generation_queue

    # ✅ Always derive provider/user from queue if not passed
    provider_id ||= queue.provider_personal_information_id
    user_id     ||= queue.user_id || 1

    provider = ProviderPersonalInformation.find(provider_id)
    user     = User.find(user_id)

    Rails.logger.info "🧾 [PDF ITEM] start item_id=#{item.id} queue_id=#{queue.id}"

    # ✅ mark item processing (only if your enum allows it, otherwise skip)
    item.update!(status: "queued") if item.status.blank?

    if item.file_name == "Verified Profile" || item.file_path == "verified_profile"
      pdf_path = render_verified_profile_pdf(provider, user)
      item.update!(status: "completed", file_path: pdf_path, message: "Verified Profile PDF generated")
    else
      handle_non_verified_item(item)
    end

    # ✅ Trigger merge when all items complete
    queue.with_lock do
      if queue.pdf_queue_items.where.not(status: "completed").count.zero? && !queue.merge_enqueued?
        queue.update!(merge_enqueued: true)
        PdfQueueMergeJob.perform_later(queue.id, provider.id, user.id)
        Rails.logger.info "🚀 [PDF ITEM] merge enqueued queue=#{queue.id}"
      end
    end
  rescue => e
    Rails.logger.error "❌ [PDF ITEM] FAILED item_id=#{item_id}: #{e.class} - #{e.message}"
    item.update!(status: "error", message: e.message) if defined?(item) && item&.persisted?
    raise e
  end

  private

  def verify_or_fail_item!(item)
    url = item.file_path.to_s.strip
    if url.blank?
      item.update!(status: "error", message: "file_path blank")
      return
    end

    if url.start_with?("http")
      verify_s3_or_http!(item, url)
    else
      local = Rails.root.join("public", url.sub(%r{^/}, ""))
      File.exist?(local) ? item.update!(status: "completed", message: "Local file ok") :
                           item.update!(status: "error", message: "Local file missing: #{local}")
    end
  end

  # S3-safe verify (does not depend on presigned URL validity)
  def verify_s3_or_http!(item, url)
    uri = URI.parse(url)

    if uri.host&.include?("amazonaws.com")
      key    = uri.path.sub(%r{^/}, "")
      bucket = ENV.fetch("AWS_BUCKET", "plmhealthoneapp-hvhs")

      s3 = Aws::S3::Client.new(
        region: ENV.fetch("AWS_REGION", "us-east-1"),
        access_key_id: ENV["AWS_ACCESS_KEY_ID"],
        secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
      )

      s3.head_object(bucket: bucket, key: key)
      item.update!(status: "completed", message: "S3 file verified")
      Rails.logger.info "✅ [PDF ITEM] S3 HEAD ok key=#{key}"
    else
      URI.open(url, open_timeout: 10, read_timeout: 20) { |f| f.read(1) }
      item.update!(status: "completed", message: "Remote file verified")
    end
  rescue => e
    item.update!(status: "error", message: "Remote file not accessible: #{e.message}")
  end

  def trigger_merge_if_ready!(queue)
    queue.with_lock do
      remaining = queue.pdf_queue_items.where.not(status: "completed").count
      Rails.logger.info "🧾 [PDF ITEM] queue=#{queue.id} remaining=#{remaining} merge_enqueued=#{queue.merge_enqueued?}"

      return unless remaining.zero?
      return if queue.merge_enqueued?

      queue.update!(merge_enqueued: true, status: "processing", message: "Merging PDFs")
      PdfQueueMergeJob.perform_later(queue.id)
      Rails.logger.info "🚀 [PDF ITEM] merge enqueued queue=#{queue.id}"
    end
  end

  # ✅ Generates Verified Profile PDF and returns PUBLIC path ("/generated_pdfs/..pdf")
  def render_verified_profile_pdf(provider, user)
    pdf_dir = Rails.root.join("public/generated_pdfs")
    FileUtils.mkdir_p(pdf_dir)

    filename = "#{provider.caqh_provider_attest_id}_verified_profile_#{Time.current.strftime('%Y%m%d%H%M%S')}.pdf"
    disk_path = pdf_dir.join(filename)

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

    pdf_binary = WickedPdf.new.pdf_from_string(html_content)
    File.open(disk_path, "wb") { |f| f.write(pdf_binary) }

    "/generated_pdfs/#{filename}"
  end
end
