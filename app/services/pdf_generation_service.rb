# app/services/pdf_generation_service.rb
require 'open-uri'
require 'combine_pdf'
require 'fileutils'
require 'wicked_pdf'
require 'mini_magick'

class PdfGenerationService
  attr_reader :queue, :provider, :user, :file_links

  def initialize(queue, provider, user)
    @queue      = queue
    @provider   = provider
    @user       = user
    @file_links = []
  end

  def process_queue!
    Rails.logger.info "Starting PDF generation for queue=#{queue.id} provider=#{provider.id}"
    queue.update!(status: 'processing', message: 'Processing PDF generation.')

    process_items_parallel!

    return queue.update!(status: 'error', message: 'No valid files to merge') if file_links.empty?

    merged_path = merge_files(file_links)
    finalize_queue(merged_path)
  rescue => e
    Rails.logger.error "PdfGenerationService FAILED: #{e.class} #{e.message}"
    queue.update!(status: 'error', message: "#{e.class}: #{e.message}")
  end

  private

  # Process each PdfQueueItem in parallel using Sidekiq
  def process_items_parallel!
    queue.pdf_queue_items.find_each do |item|
      PdfQueueItemJob.perform_later(item.id, provider.id, user.id)
    end
  end

  def merge_files(files)
    pdf_dir = Rails.root.join("public/generated_pdfs")
    FileUtils.mkdir_p(pdf_dir)

    filename = "#{provider.caqh_provider_attest_id}_#{SecureRandom.hex(5)}_#{Time.current.strftime('%Y%m%d%H%M%S')}.pdf"
    merged_pdf_path = pdf_dir.join(filename)

    combined_pdf = CombinePDF.new

    files.each do |file_url|
      temp_file = download_file(file_url)
      next unless temp_file

      begin
        if valid_pdf?(file_url)
          combined_pdf << CombinePDF.load(temp_file.path)
        else
          combined_pdf << image_to_pdf(temp_file)
        end
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

    combined_pdf.save(merged_pdf_path.to_s)
    merged_pdf_path.to_s
  end

  def finalize_queue(merged_path)
    queue.pdf_queue_items.update_all(status: 'completed', message: 'completed')
    queue.update!(
      status: 'completed',
      generated_date: Time.current,
      pdf_path: merged_path,
      message: 'PDF generated successfully',
      deleted: true
    )

    provider.update!(
      cred_status: 'psv',
      psv_completed_date: Date.today,
      progress_status: 'to_be_assigned',
      verification_status: 'completed',
      latest_audit_completed_date: Date.today
    )

    Rails.logger.info "PDF generation completed for queue=#{queue.id}"
  end

  def download_file(url)
    return nil if url.blank?

    if url.start_with?('/')
      local_path = Rails.root.join('public', url.sub(%r{^/}, ''))
      return nil unless File.exist?(local_path)
      Tempfile.new(['downloaded', '.pdf'], binmode: true).tap do |f|
        f.write(File.read(local_path))
        f.rewind
      end
    else
      Tempfile.new(['downloaded', '.pdf'], binmode: true).tap do |f|
        URI.open(url, read_timeout: 10) { |remote| f.write(remote.read) }
        f.rewind
      end
    rescue
      nil
    end
  end

  def valid_pdf?(url)
    return false if url.blank?
    if url.start_with?('/')
      path = Rails.root.join('public', url.sub(%r{^/}, ''))
      File.exist?(path) && File.open(path, 'rb') { |f| f.read(4).start_with?('%PDF') }
    else
      URI.open(url, read_timeout: 5) { |f| f.read(4).start_with?('%PDF') }
    rescue
      false
    end
  end

  def image_to_pdf(temp_file)
    img = MiniMagick::Image.open(temp_file.path)
    pdf_temp = Tempfile.new(["converted", ".pdf"], binmode: true)
    img.format("pdf")
    img.write(pdf_temp.path)
    CombinePDF.load(pdf_temp.path)
  ensure
    pdf_temp&.close
    pdf_temp&.unlink
  end
end
