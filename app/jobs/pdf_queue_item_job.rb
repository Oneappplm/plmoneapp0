# app/jobs/pdf_queue_item_job.rb
require 'aws-sdk-s3'
require 'open-uri'
require 'net/http'
require 'uri'
require 'fileutils'
require 'wicked_pdf'

class PdfQueueItemJob < ApplicationJob
  queue_as :pdf_generation

  def perform(item_id, provider_id, user_id)
    item     = PdfQueueItem.unscoped.find(item_id)
    provider = ProviderPersonalInformation.unscoped.find(provider_id)
    user     = User.unscoped.find(user_id)
    queue    = PdfGenerationQueue.unscoped.find(item.pdf_generation_queue_id)

    item.update!(status: 'processing', message: 'Processing item') if item.status == 'queued'

    Rails.logger.info "🧾 [PDF ITEM] Processing PdfQueueItem #{item.id} for queue #{queue.id}"

    if item.file_name == "Verified Profile"
      pdf_path = render_verified_profile_pdf(provider, user)
      item.update!(status: 'completed', file_path: pdf_path, message: 'Verified Profile PDF generated')
      Rails.logger.info "✅ [PDF ITEM] Verified Profile generated for item #{item.id} -> #{pdf_path}"
    else
      handle_non_verified_item(item)
    end

    # 🚀 Trigger merge when all items are complete
    queue.with_lock do
      all_done = queue.pdf_queue_items.where.not(status: 'completed').count.zero?
      if all_done && !queue.merge_enqueued?
        queue.update!(merge_enqueued: true)
        PdfQueueMergeJob.perform_later(queue.id, provider.id, user.id)
        Rails.logger.info "🚀 [PDF ITEM] All items completed. Enqueued merge job for queue #{queue.id}"
      end
    end
  rescue => e
    Rails.logger.error "❌ [PDF ITEM] FAILED item_id=#{item_id}: #{e.class} - #{e.message}\n#{e.backtrace.first(10).join("\n")}"
    PdfQueueItem.unscoped.where(id: item_id).update_all(status: 'error', message: e.message)
  end

  private

  def handle_non_verified_item(item)
    file_path_value = item.file_path.to_s.strip

    if file_path_value.blank?
      item.update!(status: 'error', message: 'File path blank')
      Rails.logger.warn "⚠️ [PDF ITEM] Blank file_path for item #{item.id}"
      return
    end

    if remote_url?(file_path_value)
      if remote_accessible?(file_path_value)
        item.update!(status: 'completed', message: 'Remote file verified')
        Rails.logger.info "🌐 [PDF ITEM] Remote file verified for item #{item.id}"
      else
        item.update!(status: 'error', message: 'Remote file not accessible')
        Rails.logger.warn "⚠️ [PDF ITEM] Remote file inaccessible for item #{item.id}: #{file_path_value}"
      end
    else
      local_path = Rails.root.join('public', file_path_value.sub(%r{^/}, ''))
      if File.exist?(local_path)
        item.update!(status: 'completed', message: 'File ready for merge')
        Rails.logger.info "📁 [PDF ITEM] Local file exists for item #{item.id}: #{local_path}"
      else
        item.update!(status: 'error', message: "File missing: #{local_path}")
        Rails.logger.warn "⚠️ [PDF ITEM] Missing local file for item #{item.id}: #{local_path}"
      end
    end
  end

  def remote_accessible?(url)
    uri = URI.parse(url)

    if uri.host&.include?("amazonaws.com")
      key    = uri.path.sub(%r{^/}, '')
      bucket = ENV.fetch("AWS_BUCKET", "plmhealthoneapp-hvhs")

      s3 = Aws::S3::Client.new(
        region: ENV.fetch("AWS_REGION", "us-east-1"),
        access_key_id: ENV["AWS_ACCESS_KEY_ID"],
        secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
      )

      s3.head_object(bucket: bucket, key: key)
      Rails.logger.info "✅ [PDF ITEM] S3 HEAD successful for #{key}"
      true
    else
      URI.open(url, open_timeout: 10, read_timeout: 20) { |f| f.read(1) }
      true
    end
  rescue Aws::S3::Errors::NotFound
    Rails.logger.warn "⚠️ [PDF ITEM] S3 object missing"
    false
  rescue => e
    Rails.logger.error "❌ [PDF ITEM] Remote check failed: #{e.class} - #{e.message}"
    false
  end

  def remote_url?(str)
    str.match?(/\Ahttps?:\/\//i)
  end

  def render_verified_profile_pdf(provider, user)
    pdf_dir = Rails.root.join("public/generated_pdfs")
    FileUtils.mkdir_p(pdf_dir)

    filename = "#{provider.caqh_provider_attest_id}_verified_profile_#{Time.current.strftime('%Y%m%d%H%M%S')}.pdf"
    pdf_path = pdf_dir.join(filename)

    html_content = ApplicationController.render(
      template: 'mhc/verification_platform/verified_profile_pdf',
      layout: 'pdf',
      locals: {
        provider_personal_information: provider,
        user: user,
        oig_details: provider.rva_informations.where(tab: 'OIG', status: 'completed').where.not(source_date: nil),
        npdb_details: provider.rva_informations.where(tab: 'NPDB'),
        grouped_disclosures: provider.provider_disclosures
          .where(disclosure_answer_flag: true)
          .where.not(disclosure_explanation: [nil, ""])
          .group_by do |d|
            QUESTIONS_DISCLOSURE.find { |_h, qs| qs.include?(d.disclosure_question_disclosure_summary) }&.first
          end
      }
    )

    pdf_file = WickedPdf.new.pdf_from_string(html_content)
    File.open(pdf_path, 'wb') { |f| f.write(pdf_file) }

    "/generated_pdfs/#{filename}"
  end
end
