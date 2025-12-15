# app/services/pdf_generation_service.rb
require 'open-uri'
require 'combine_pdf'
require 'fileutils'
require 'wicked_pdf'
require 'mini_magick'
require 'securerandom'

class PdfGenerationService
  attr_reader :queue, :provider, :user, :file_links

  def initialize(queue, provider, user)
    @queue      = queue
    @provider   = provider
    @user       = user
    @file_links = []
  end

  def process_queue!
    Rails.logger.info "Starting PDF generation for queue=#{queue.id} provider=#{provider.id} user=#{user.id}"

    queue.update!(
      status: 'processing',
      message: 'Processing started',
      merge_enqueued: false,
      queued_date: queue.queued_date || Time.current
    )

    process_items_parallel!

    # IMPORTANT:
    # This pipeline is async. Merge happens in PdfQueueMergeJob after all items complete.
    # So we do NOT try to merge here.

    true
  rescue => e
    Rails.logger.error "PdfGenerationService FAILED queue=#{queue.id}: #{e.class} #{e.message}\n#{e.backtrace.first(10).join("\n")}"
    queue.update!(status: 'error', message: "#{e.class}: #{e.message}")
    false
  end

  private

  def process_items_parallel!
    queue.pdf_queue_items.find_each do |item|
      # queue stores provider_personal_information_id and user_id
      PdfQueueItemJob.perform_later(item.id, queue.provider_personal_information_id, queue.user_id)
    end
  end

  # --- Existing merge helpers kept (not used by async flow) ---

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

  def download_file(url)
    return nil if url.blank?

    if url.start_with?('/')
      local_path = Rails.root.join('public', url.sub(%r{^/}, ''))
      return nil unless File.exist?(local_path)

      Tempfile.new(['downloaded', File.extname(local_path)], binmode: true).tap do |f|
        f.write(File.binread(local_path))
        f.rewind
      end
    else
      Tempfile.new(['downloaded', File.extname(URI.parse(url).path)], binmode: true).tap do |f|
        URI.open(url, read_timeout: 20, open_timeout: 10) { |remote| IO.copy_stream(remote, f) }
        f.rewind
      end
    end
  rescue => e
    Rails.logger.error "Download failed for #{url}: #{e.class} #{e.message}"
    nil
  end

  def valid_pdf?(url)
    return false if url.blank?
    if url.start_with?('/')
      path = Rails.root.join('public', url.sub(%r{^/}, ''))
      File.exist?(path) && File.open(path, 'rb') { |f| f.read(4).start_with?('%PDF') }
    else
      URI.open(url, read_timeout: 10, open_timeout: 10) { |f| f.read(4).start_with?('%PDF') }
    end
  rescue
    false
  end

  def image_to_pdf(temp_file)
    pdf_temp = Tempfile.new(["converted", ".pdf"], binmode: true)
    begin
      img = MiniMagick::Image.open(temp_file.path)
      img.format("pdf")
      img.write(pdf_temp.path)
      CombinePDF.load(pdf_temp.path)
    ensure
      pdf_temp.close
      pdf_temp.unlink
    end
  end
end
