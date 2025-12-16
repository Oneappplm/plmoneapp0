require "aws-sdk-s3"
require "combine_pdf"
require "fileutils"
require "mini_magick"
require "tempfile"
require "uri"
require "open-uri"

class PdfQueueMergeJob < ApplicationJob
  queue_as :pdf_generation

  def perform(queue_id)
    queue    = PdfGenerationQueue.unscoped.find(queue_id)
    provider = ProviderPersonalInformation.unscoped.find(queue.provider_personal_information_id)

    Rails.logger.info "📄 [PDF MERGE] Starting merge for queue #{queue.id}"

    file_links = queue.pdf_queue_items.where(status: "completed").order(:id).pluck(:file_path)
    if file_links.empty?
      Rails.logger.warn "⚠️ [PDF MERGE] No completed files for queue #{queue.id}"
      queue.update!(status: "error", message: "No completed files to merge")
      return
    end

    merged_disk_path = merge_files_to_disk(file_links, provider) # ✅ returns DISK path

    # ✅ Upload to SavedProfile safely (File.open needs DISK path)
    queue.create_saved_profile!(file_path: File.open(merged_disk_path), file_type: "pdf")

    # Optional: delete merged file after upload
    File.delete(merged_disk_path) if File.exist?(merged_disk_path)

    queue.update!(
      status: "completed",
      generated_date: Time.current,
      pdf_path: queue.saved_profile.file_path.url,  # or set this however you want
      message: "PDF generated successfully",
      deleted: true
    )

    Rails.logger.info "✅ [PDF MERGE] Completed queue #{queue.id}"
  rescue => e
    Rails.logger.error "❌ [PDF MERGE] FAILED queue=#{queue_id}: #{e.class} #{e.message}\n#{e.backtrace.first(12).join("\n")}"
    PdfGenerationQueue.unscoped.where(id: queue_id).update_all(status: "error", message: "#{e.class}: #{e.message}")
  end

  private

  # Returns DISK path like ".../public/generated_pdfs/xxx.pdf"
  def merge_files_to_disk(files, provider)
    pdf_dir = Rails.root.join("public/generated_pdfs")
    FileUtils.mkdir_p(pdf_dir)

    filename = "#{provider.caqh_provider_attest_id}_merged_#{Time.current.strftime('%Y%m%d%H%M%S')}.pdf"
    merged_disk_path = pdf_dir.join(filename)

    combined_pdf = CombinePDF.new

    files.each do |file_ref|
      next if file_ref.blank?

      if http_url?(file_ref)
        add_remote!(combined_pdf, file_ref)
      else
        add_local!(combined_pdf, file_ref)
      end
    end

    combined_pdf.save(merged_disk_path.to_s)
    Rails.logger.info "💾 [MERGE] Saved merged PDF: #{merged_disk_path}"
    merged_disk_path.to_s
  end

  def add_local!(combined_pdf, public_or_relative_path)
    disk_path = Rails.root.join("public", public_or_relative_path.sub(%r{^/}, ""))
    unless File.exist?(disk_path)
      Rails.logger.warn "⚠️ [MERGE] Missing local file: #{disk_path}"
      return
    end

    ext = File.extname(disk_path.to_s).downcase
    if image_ext?(ext)
      combined_pdf << image_path_to_pdf(disk_path.to_s)
    else
      combined_pdf << CombinePDF.load(disk_path.to_s, allow_optional_content: true)
    end
  end

  # S3-safe: downloads by key (no presigned expiry issues)
  def add_remote!(combined_pdf, url)
    uri = URI.parse(url)
    ext = File.extname(uri.path).downcase

    tmp = Tempfile.new(["merge_", ext.presence || ".bin"], Rails.root.join("tmp"))

    begin
      if uri.host&.include?("amazonaws.com")
        bucket = ENV.fetch("AWS_BUCKET", "plmhealthoneapp-hvhs")
        key    = uri.path.sub(%r{^/}, "")

        s3 = Aws::S3::Client.new(
          region: ENV.fetch("AWS_REGION", "us-east-1"),
          access_key_id: ENV["AWS_ACCESS_KEY_ID"],
          secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
        )

        s3.get_object(bucket: bucket, key: key, response_target: tmp.path)
      else
        URI.open(url, open_timeout: 15, read_timeout: 30) { |f| IO.copy_stream(f, tmp) }
      end

      if image_ext?(ext)
        combined_pdf << image_path_to_pdf(tmp.path)
      else
        combined_pdf << CombinePDF.load(tmp.path, allow_optional_content: true)
      end
    ensure
      tmp.close
      tmp.unlink
    end
  rescue => e
    Rails.logger.error "❌ [MERGE] Failed add remote: #{url} - #{e.class}: #{e.message}"
  end

  def image_path_to_pdf(path)
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

  def http_url?(str)
    str.match?(/\Ahttps?:\/\//i)
  end

  def image_ext?(ext)
    ext.to_s.match?(/\.(png|jpg|jpeg)$/i)
  end
end
