# app/jobs/pdf_queue_merge_job.rb
class PdfQueueMergeJob < ApplicationJob
  queue_as :pdf_generation

  def perform(queue_id, provider_id, user_id)
    queue = PdfGenerationQueue.find(queue_id)
    provider = ProviderPersonalInformation.find(provider_id)
    user = User.find(user_id)

    Rails.logger.info "📄 [PDF MERGE] Starting merge for queue #{queue.id}"

    # Collect completed files
    file_links = []
    verified_item = queue.pdf_queue_items.find_by(file_name: "Verified Profile", status: "completed")
    file_links << verified_item.file_path if verified_item
    file_links.concat(queue.pdf_queue_items.where.not(file_name: "Verified Profile").where(status: "completed").pluck(:file_path))

    if file_links.empty?
      Rails.logger.warn "⚠️ [PDF MERGE] No completed PDFs found for queue #{queue.id}"
      return
    end

    merged_pdf_path = merge_files(file_links, provider)
    Rails.logger.info "✅ [PDF MERGE] Created merged file: #{merged_pdf_path}"

    # Save final merged file to SavedProfile (CarrierWave)
    queue.create_saved_profile!(file_path: File.open(merged_pdf_path), file_type: "pdf")

    # 🧹 Cleanup temporary files and folders
    clean_up_temp_files(queue, verified_item, file_links)

    # Remove merged file from local disk after upload
    if File.exist?(merged_pdf_path)
      File.delete(merged_pdf_path)
      Rails.logger.info "🗑️ [CLEANUP] Deleted merged file: #{merged_pdf_path}"
    end

    # Update queue and provider status
    queue.update!(
      status: "completed",
      generated_date: Time.current,
      pdf_path: merged_pdf_path,
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
    Rails.logger.error "❌ [PDF MERGE] FAILED for queue #{queue_id}: #{e.class} - #{e.message}"
    queue.update(status: "error", message: e.message) if queue
  end

  private

  def merge_files(files, provider)
    pdf_dir = Rails.root.join("public/generated_pdfs")
    FileUtils.mkdir_p(pdf_dir)
    filename = "#{provider.caqh_provider_attest_id}_merged_#{Time.current.strftime('%Y%m%d%H%M%S')}.pdf"
    merged_path = pdf_dir.join(filename)

    combined_pdf = CombinePDF.new

    files.each do |file_url|
      # Detect if it's an S3 or HTTP(S) URL
      if file_url =~ URI::DEFAULT_PARSER.make_regexp(%w[http https])
        Rails.logger.info "🌐 [MERGE] Downloading remote file: #{file_url}"

        begin
          # Download temporarily
          tempfile = Tempfile.new(['remote_pdf', '.pdf'], Rails.root.join('tmp'))
          URI.open(file_url) do |remote_file|
            tempfile.write(remote_file.read)
            tempfile.rewind
          end
          combined_pdf << CombinePDF.load(tempfile.path)
        ensure
          tempfile.close!
        end
      else
        # Handle local files
        path = Rails.root.join("public", file_url.sub(%r{^/}, ""))
        if File.exist?(path)
          combined_pdf << CombinePDF.load(path)
          Rails.logger.info "📎 [MERGE] Added local file: #{path}"
        else
          Rails.logger.warn "⚠️ [MERGE] Missing local file: #{path}"
        end
      end
    end

    combined_pdf.save(merged_path)
    Rails.logger.info "💾 [MERGE] Saved merged file at: #{merged_path}"
    merged_path.to_s
  end
  
  # 🧹 Cleanup helper
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
