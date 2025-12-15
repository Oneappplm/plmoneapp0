# app/jobs/pdf_queue_merge_job.rb
require 'aws-sdk-s3'
require 'combine_pdf'
require 'open-uri'
require 'fileutils'
require 'mini_magick'
require 'tempfile'
require 'uri'

class PdfQueueMergeJob < ApplicationJob
  queue_as :pdf_generation

  def perform(queue_id, provider_id, user_id)
    queue    = PdfGenerationQueue.unscoped.find(queue_id)
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

    # Cleanup
    clean_up_temp_files(queue, verified_item, file_links)

    if File.exist?(merged_pdf_path)
      File.delete(merged_pdf_path)
      Rails.logger.info "🗑️ [CLEANUP] Deleted merged file: #{merged_pdf_path}"
    end

    saved_url =
      if saved_profile.respond_to?(:file_path) && saved_profile.file_path.respond_to?(:url)
        saved_profile.file_path.url
      end

    queue.update!(
      status: "completed",
      generated_date: Time.current,
      pdf_path: (saved_url.presence || "uploaded"),
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

    Rails.logger.info "✅ [PDF MERGE] Queue #{queue.id} merged and cleaned successfully"
  rescue => e
    Rails.logger.error "❌ [PDF MERGE] FAILED for queue #{queue_id}: #{e.class} - #{e.message}\n#{e.backtrace.first(10).join("\n")}"
    PdfGenerationQueue.unscoped.where(id: queue_id).update_all(status: "error", message: e.message)
  end

  private

  def merge_files(files, provider)
    pdf_dir = Rails.root.join("public/generated_pdfs")
    FileUtils.mkdir_p(pdf_dir)

    filename = "#{provider.caqh_provider_attest_id}_merged_#{Time.current.strftime('%Y%m%d%H%M%S')}.pdf"
    merged_path = pdf_dir.join(filename)

    combined_pdf = CombinePDF.new

    files.each do |file_url|
      next if file_url.blank?

      if file_url =~ URI::DEFAULT_PARSER.make_regexp(%w[http https])
        add_remote!(combined_pdf, file_url)
      else
        add_local!(combined_pdf, file_url)
      end
    end

    combined_pdf.save(merged_path.to_s)
    Rails.logger.info "💾 [MERGE] Saved merged file at: #{merged_path}"
    merged_path.to_s
  end

  def add_remote!(combined_pdf, url)
    uri = URI.parse(url)

    tmp = Tempfile.new(["remote_", File.extname(uri.path).presence || ".bin"])
    begin
      URI.open(url, open_timeout: 15, read_timeout: 30) { |f| IO.copy_stream(f, tmp) }
      tmp.flush

      if image_ext?(uri.path)
        combined_pdf << image_file_to_pdf(tmp.path)
      else
        combined_pdf << CombinePDF.load(tmp.path, allow_optional_content: true)
      end

      Rails.logger.info "📎 [MERGE] Added remote file: #{url}"
    rescue => e
      Rails.logger.error "❌ [MERGE] Failed remote file #{url}: #{e.class} - #{e.message}"
    ensure
      tmp.close
      tmp.unlink
    end
  end

  def add_local!(combined_pdf, file_url)
    path = Rails.root.join("public", file_url.sub(%r{^/}, ""))
    if File.exist?(path)
      if image_ext?(path.to_s)
        combined_pdf << image_file_to_pdf(path.to_s)
      else
        combined_pdf << CombinePDF.load(path.to_s, allow_optional_content: true)
      end
      Rails.logger.info "📎 [MERGE] Added local file: #{path}"
    else
      Rails.logger.warn "⚠️ [MERGE] Missing local file: #{path}"
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

  def image_ext?(path)
    path.to_s.match?(/\.(png|jpg|jpeg)$/i)
  end

  # --- your existing cleanup kept ---
  def clean_up_temp_files(queue, verified_item, file_links)
    Rails.logger.info "🧹 [CLEANUP] Starting cleanup of temporary and upload files"

    delete_path(Rails.root.join("public", verified_item.file_path.sub(%r{^/}, "")), "Verified Profile") if verified_item&.file_path.present?

    queue.pdf_queue_items.where(temporary: true).each do |temp_item|
      next unless temp_item.file_path.present?
      delete_path(Rails.root.join("public", temp_item.file_path.sub(%r{^/}, "")), "Temporary Uploaded File")
    end

    file_links.each do |path|
      full_path = Rails.root.join("public", path.sub(%r{^/}, ""))
      next unless full_path.to_s.include?("/uploads/")
      delete_path(full_path, "Uploaded Source File")
    end

    clean_empty_upload_dirs
  end

  def delete_path(path, label)
    if File.exist?(path)
      if File.directory?(path)
        FileUtils.rm_rf(path)
        Rails.logger.info "🗑️ [CLEANUP] Deleted directory (#{label}): #{path}"
      else
        File.delete(path)
        Rails.logger.info "🗑️ [CLEANUP] Deleted file (#{label}): #{path}"
      end
    else
      Rails.logger.warn "⚠️ [CLEANUP] #{label} missing: #{path}"
    end
  end

  def clean_empty_upload_dirs
    uploads_root = Rails.root.join("public/uploads")
    Dir.glob("#{uploads_root}/**/*").select { |d| File.directory?(d) }.each do |dir|
      next unless (Dir.entries(dir) - %w[. ..]).empty?
      Dir.rmdir(dir)
      Rails.logger.info "🧹 [CLEANUP] Removed empty uploads dir: #{dir}"
    end
  end
end
