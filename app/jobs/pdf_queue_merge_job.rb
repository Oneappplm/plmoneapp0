# app/jobs/pdf_queue_merge_job.rb
require 'aws-sdk-s3'
require 'combine_pdf'
require 'open-uri'
require 'fileutils'
require 'mini_magick'

class PdfQueueMergeJob < ApplicationJob
  queue_as :pdf_generation

  def perform(queue_id, provider_id, user_id)
    queue = PdfGenerationQueue.unscoped.find_by(id: queue_id)
    unless queue
      Rails.logger.error "❌ [PDF MERGE] Queue not found queue_id=#{queue_id}"
      return
    end

    provider = ProviderPersonalInformation.unscoped.find(provider_id)
    user     = User.unscoped.find(user_id)

    Rails.logger.info "📄 [PDF MERGE] Starting merge for queue #{queue.id}"

    file_links = []
    verified_item = queue.pdf_queue_items.find_by(file_name: "Verified Profile", status: "completed")
    file_links << verified_item.file_path if verified_item&.file_path.present?
    file_links.concat(queue.pdf_queue_items.where.not(file_name: "Verified Profile").where(status: "completed").pluck(:file_path))

    if file_links.empty?
      Rails.logger.warn "⚠️ [PDF MERGE] No completed PDFs found for queue #{queue.id}"
      queue.update!(status: "error", message: "No completed files to merge")
      return
    end

    merged_pdf_path = merge_files(file_links, provider)
    Rails.logger.info "✅ [PDF MERGE] Created merged file: #{merged_pdf_path}"

    saved_profile = queue.create_saved_profile!(file_path: File.open(merged_pdf_path), file_type: "pdf")

    # cleanup local merged after upload
    if File.exist?(merged_pdf_path)
      File.delete(merged_pdf_path)
      Rails.logger.info "🗑️ [CLEANUP] Deleted merged file: #{merged_pdf_path}"
    end

    # Prefer the uploaded URL (CarrierWave) instead of local deleted path
    saved_url =
      if saved_profile.respond_to?(:file_path) && saved_profile.file_path.respond_to?(:url)
        saved_profile.file_path.url
      end

    queue.update!(
      status: "completed",
      generated_date: Time.current,
      pdf_path: (saved_url.presence || "(uploaded)"),
      message: "PDF generated successfully",
      deleted: true
    )

    provider.update!(
      cred_status: "psv",
      psv_completed_date: Date.today,
      progress_status: "to_be_assigned",
      verification_status: "completed",
      latest_audit_completed_date: Date.today
    )

    Rails.logger.info "✅ [PDF MERGE] Queue #{queue.id} merged successfully"

  rescue => e
    Rails.logger.error "❌ [PDF MERGE] FAILED queue_id=#{queue_id}: #{e.class} - #{e.message}\n#{e.backtrace.first(10).join("\n")}"
    PdfGenerationQueue.unscoped.where(id: queue_id).update_all(status: "error", message: e.message)
  end

  private

  def merge_files(files, provider)
    pdf_dir = Rails.root.join("public/generated_pdfs")
    FileUtils.mkdir_p(pdf_dir)

    filename = "#{provider.caqh_provider_attest_id}_merged_#{Time.current.strftime('%Y%m%d%H%M%S')}.pdf"
    merged_path = pdf_dir.join(filename)

    combined_pdf = CombinePDF.new

    files.each do |file_ref|
      next if file_ref.blank?

      if s3_key_path?(file_ref)
        add_from_s3_key!(combined_pdf, file_ref)
        next
      end

      if remote_url?(file_ref)
        add_from_remote_url!(combined_pdf, file_ref)
        next
      end

      # Local file under public/
      local_path = Rails.root.join("public", file_ref.sub(%r{^/}, ""))
      if File.exist?(local_path)
        if image_ext?(local_path.to_s)
          combined_pdf << image_file_to_pdf(local_path.to_s)
        else
          combined_pdf << CombinePDF.load(local_path.to_s, allow_optional_content: true)
        end
        Rails.logger.info "📎 [MERGE] Added local file: #{local_path}"
      else
        Rails.logger.warn "⚠️ [MERGE] Missing local file: #{local_path}"
      end
    end

    combined_pdf.save(merged_path.to_s)
    Rails.logger.info "💾 [MERGE] Saved merged file at: #{merged_path}"
    merged_path.to_s
  end

  def add_from_s3_key!(combined_pdf, key)
    bucket = ENV.fetch("AWS_BUCKET", "plmhealthoneapp-hvhs")

    s3 = Aws::S3::Client.new(
      region: ENV.fetch("AWS_REGION", "us-east-1"),
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    )

    tmp_file = Tempfile.new(["s3_download_", File.extname(key).presence || ".bin"], Rails.root.join("tmp"))

    begin
      Rails.logger.info "🌐 [MERGE] Fetching from S3 key: #{key}"
      s3.get_object(bucket: bucket, key: key, response_target: tmp_file.path)

      if image_ext?(key)
        combined_pdf << image_file_to_pdf(tmp_file.path)
      else
        combined_pdf << CombinePDF.load(tmp_file.path, allow_optional_content: true)
      end

      Rails.logger.info "📎 [MERGE] Added S3 key: #{key}"
    rescue Aws::S3::Errors::NoSuchKey
      Rails.logger.error "⚠️ [MERGE] S3 key not found: #{key}"
    rescue => e
      Rails.logger.error "❌ [MERGE] Failed S3 key #{key}: #{e.class} - #{e.message}"
    ensure
      tmp_file.close
      tmp_file.unlink
    end
  end

  def add_from_remote_url!(combined_pdf, url)
    uri = URI.parse(url)

    # If it's a full S3 URL, fetch by key
    if uri.host&.include?("amazonaws.com")
      key = uri.path.sub(%r{^/}, '')
      add_from_s3_key!(combined_pdf, key)
      return
    end

    tmp_file = Tempfile.new(["remote_download_", File.extname(uri.path).presence || ".bin"])
    begin
      URI.open(url, open_timeout: 10, read_timeout: 20) do |remote_file|
        IO.copy_stream(remote_file, tmp_file)
      end

      if image_ext?(url)
        combined_pdf << image_file_to_pdf(tmp_file.path)
      else
        combined_pdf << CombinePDF.load(tmp_file.path, allow_optional_content: true)
      end

      Rails.logger.info "📎 [MERGE] Added remote file: #{url}"
    rescue => e
      Rails.logger.error "❌ [MERGE] Failed remote file #{url}: #{e.class} - #{e.message}"
    ensure
      tmp_file.close
      tmp_file.unlink
    end
  end

  def image_file_to_pdf(path)
    pdf_temp = Tempfile.new(["converted", ".pdf"], binmode: true)
    begin
      img = MiniMagick::Image.open(path)
      img.format("pdf")
      img.write(pdf_temp.path)
      CombinePDF.load(pdf_temp.path)
    ensure
      pdf_temp.close
      pdf_temp.unlink
    end
  end

  def s3_key_path?(path)
    path.start_with?("uploads/")
  end

  def remote_url?(str)
    str.match?(/\Ahttps?:\/\//i)
  end

  def image_ext?(path)
    path.to_s.match?(/\.(png|jpg|jpeg)$/i)
  end
end
