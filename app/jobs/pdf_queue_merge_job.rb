# app/jobs/pdf_queue_merge_job.rb
require "aws-sdk-s3"
require "combine_pdf"
require "fileutils"
# require "mini_magick"
require "tempfile"
require "uri"
require "open-uri"
require "prawn"
require "tmpdir"

class PdfQueueMergeJob < ApplicationJob
  queue_as :pdf_generation

  # Backward-compatible: allow extra args even if we don’t use them
  def perform(queue_id, _provider_id = nil, _user_id = nil)
    queue    = PdfGenerationQueue.unscoped.find(queue_id)
    provider = ProviderPersonalInformation.unscoped.find(queue.provider_personal_information_id)

    Rails.logger.info "📄 [PDF MERGE] Starting merge queue=#{queue.id}"

    # Mark queue as merging (optional but helpful for UI)
    queue.update!(status: "processing", message: "Merging PDFs...") if queue.status == "processing" || queue.status == "queued"

    items = queue.pdf_queue_items.order(:id).to_a

    raise "No PDF queue items found" if items.empty?

    invalid_items = items.reject do |item|
      item.status == "completed" && item.file_path.present?
    end

    if invalid_items.any?
      raise "Cannot merge queue #{queue.id}. Invalid item IDs: #{invalid_items.map(&:id).join(', ')}"
    end

    file_links = items.map(&:file_path)

    # if file_links.empty?
    #   Rails.logger.warn "⚠️ [PDF MERGE] No completed files queue=#{queue.id}"
    #   queue.update!(status: "error", message: "No completed files to merge")
    #   return
    # end

    merged_disk_path = merge_files_to_disk(file_links, provider)

    # Upload merged file
    File.open(merged_disk_path, "rb") do |f|
      queue.create_saved_profile!(file_path: f, file_type: "pdf")
    end

    File.delete(merged_disk_path) if File.exist?(merged_disk_path)

    queue.update!(
      status: "completed",
      generated_date: Time.current,
      pdf_path: queue.saved_profile.file_path.url,
      message: "PDF generated successfully",
      deleted: true
    )

    # ✅ Update provider credential status to PSV
    provider.update_columns(
      cred_status: "psv",
      progress_status: "to_be_assigned"
    )
    
    Rails.logger.info "✅ [PDF MERGE] Completed queue=#{queue.id}"
  rescue => e
    Rails.logger.error "❌ [PDF MERGE] FAILED queue=#{queue_id}: #{e.class} #{e.message}"
    Rails.logger.error e.backtrace.first(15).join("\n")
    PdfGenerationQueue.unscoped.where(id: queue_id).update_all(status: "error", message: "#{e.class}: #{e.message}")
    raise e
  end

  private

  # ---------- Fast path: write to tmp/ not public/ ----------
  def merge_files_to_disk(files, provider)
    FileUtils.mkdir_p(Rails.root.join("tmp"))

    filename = "#{provider.caqh_provider_attest_id}_merged_#{Time.current.strftime('%Y%m%d%H%M%S')}.pdf"
    merged_disk_path = Rails.root.join("tmp", filename)

    combined_pdf = CombinePDF.new

    files.each_with_index do |file_ref, idx|
      raise ArgumentError, "Blank attachment path at position #{idx + 1}" if file_ref.blank?
      begin
        Rails.logger.info "📎 [MERGE] (#{idx + 1}/#{files.size}) adding: #{short(file_ref)}"
        http_url?(file_ref) ? add_remote!(combined_pdf, file_ref) : add_local!(combined_pdf, file_ref)
      rescue => e
        Rails.logger.error "❌ [MERGE] Failed file: #{short(file_ref)} - #{e.class}: #{e.message}"
        raise
      end
    end

    combined_pdf.save(merged_disk_path.to_s)
    Rails.logger.info "💾 [MERGE] Saved merged PDF: #{merged_disk_path}"
    merged_disk_path.to_s
  end

  def add_local!(combined_pdf, public_or_relative_path)
    disk_path = Rails.root.join("public", public_or_relative_path.to_s.sub(%r{^/}, ""))

    unless File.file?(disk_path)
      raise Errno::ENOENT, "Missing local PDF attachment: #{disk_path}"
    end

    ext = File.extname(disk_path.to_s).downcase

    if image_ext?(ext)
      combined_pdf << image_path_to_pdf(disk_path.to_s)
    else
      # allow_optional_content: true is slower; only enable if you must
      combined_pdf << CombinePDF.load(disk_path.to_s)
    end
  end

  def add_remote!(combined_pdf, url)
    uri = URI.parse(url)
    ext = File.extname(uri.path).downcase
    ext = ".bin" if ext.blank?

    tmp = Tempfile.new(["merge_", ext], Rails.root.join("tmp"))
    tmp.binmode

    begin
      if uri.host&.include?("amazonaws.com")
        s3.get_object(
          bucket: aws_bucket,
          key: uri.path.sub(%r{^/}, ""),
          response_target: tmp.path
        )
      else
        URI.open(url, open_timeout: 10, read_timeout: 30) { |f| IO.copy_stream(f, tmp) }
      end

      if image_ext?(ext)
        combined_pdf << image_path_to_pdf(tmp.path)
      else
        combined_pdf << CombinePDF.load(tmp.path)
      end
    ensure
      tmp.close
      tmp.unlink
    end
  rescue => e
    Rails.logger.error "❌ [MERGE] Failed remote: #{short(url)} - #{e.class}: #{e.message}"
    raise
  end

  # ---------- Shared clients/config ----------
  def s3
    @s3 ||= Aws::S3::Client.new(
      region: ENV.fetch("AWS_REGION", "us-east-1"),
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    )
  end

  def aws_bucket
    ENV.fetch("AWS_BUCKET", "docgotest-bucket")
  end

  # ---------- Utils ----------
  def http_url?(str)
    str.to_s.match?(/\Ahttps?:\/\//i)
  end

  def image_ext?(ext)
    ext.to_s.match?(/\.(png|jpg|jpeg|tif|tiff)$/i)
  end

  def image_path_to_pdf(path)
    ext = File.extname(path).downcase

    return tiff_to_pdf(path) if %w[.tif .tiff].include?(ext)

    pdf_temp = Tempfile.new(["converted_", ".pdf"], Rails.root.join("tmp"))
    pdf_temp.binmode

    begin
      Prawn::Document.generate(pdf_temp.path, page_size: "A4") do |pdf|
        pdf.image path, fit: [pdf.bounds.width, pdf.bounds.height]
      end

      CombinePDF.load(pdf_temp.path)
    ensure
      pdf_temp.close
      pdf_temp.unlink
    end
  end

  def tiff_to_pdf(path)
    Dir.mktmpdir("tiff_merge_", Rails.root.join("tmp")) do |dir|
      output_pattern = File.join(dir, "page-%04d.png")

      success = system(
        "/usr/bin/convert",
        path.to_s,
        output_pattern
      )

      raise "TIFF conversion failed" unless success

      pages = Dir.glob(File.join(dir, "page-*.png")).sort

      raise "TIFF conversion produced no pages" if pages.empty?

      combined = CombinePDF.new

      pages.each do |page_path|
        combined << image_path_to_pdf(page_path)
      end

      combined
    end
  end

  def short(str)
    s = str.to_s
    s.length > 120 ? "#{s[0..110]}..." : s
  end
end
