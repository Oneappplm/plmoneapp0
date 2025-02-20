require 'open-uri'
require 'combine_pdf'
require 'fileutils'

class PdfGenerationJob < ApplicationJob
  queue_as :default

  def perform(queue_id, provider)
    queue = PdfGenerationQueue.find_by(id: queue_id)
    return if queue.nil?

    # Update all queued items to 'sent' with a delay
    sleep(2)
    queue.pdf_queue_items.update_all(status: 'sent')
    queue.update!(status: 'sent', message: 'Processing PDF generation.')

    begin
      # Extract queued files
      queue.pdf_queue_items.each do |item|
        file_url = item.file_path

        if !file_exists?(file_url)
          item.update!(status: 'error', message: 'File not found.')
        elsif !valid_pdf?(file_url)
          item.update!(status: 'error', message: 'File not a valid PDF.')
        end
      end

      # If any item has an error, stop processing
      if queue.pdf_queue_items.where(status: 'error').exists?
        queue.update!(status: 'error', message: 'One or more files are invalid or missing.')
        return
      end

      # Generate PDF
      file_links = queue.pdf_queue_items.pluck(:file_path)
      pdf_path = generate_pdf(file_links, provider, queue)

      # Delay before marking items as completed
      sleep(2)
      queue.pdf_queue_items.update_all(status: 'completed')

      # Update queue status and set PDF path
      queue.update!(status: 'completed', generated_date: Time.current, pdf_path: pdf_path)

      # Delay before deleting the queue
      sleep(5)
      queue.update!(deleted: true)

    rescue => e
      sleep(2)
      queue.update!(status: 'error', message: e.message)
    end
  end

  private

  def generate_pdf(files, provider, queue)
    # Ensure the directory exists
    pdf_dir = Rails.root.join("public/generated_pdfs")
    FileUtils.mkdir_p(pdf_dir)

    # Generate unique PDF filename
    filename = "#{provider.caqh_provider_attest_id}_#{SecureRandom.hex(5)}_#{Time.current.strftime('%Y%m%d%H%M%S')}.pdf"
    merged_pdf_path = pdf_dir.join(filename)

    # Initialize new combined PDF
    combined_pdf = CombinePDF.new

    files.each do |file_url|
      temp_file = download_file(file_url)

      if temp_file
        begin
          combined_pdf << CombinePDF.load(temp_file.path)
        rescue => e
          Rails.logger.error "Error processing file: #{file_url} - #{e.message}"
        ensure
          temp_file.close
          temp_file.unlink
        end
      else
        Rails.logger.warn "Skipping missing file: #{file_url}"
      end
    end

    # Save the merged PDF
    combined_pdf.save(merged_pdf_path)

    # Save the new PDF in the SavedFile model
    saved_profile = queue.create_saved_profile!(
      file_path: merged_pdf_path.to_s,
      file_type: 'pdf'
    )
    saved_profile.update!(file_path: File.open(merged_pdf_path))

    merged_pdf_path.to_s
  end

  def download_file(url)
    return nil if url.blank?

    temp_file = Tempfile.new(['downloaded', '.pdf'], binmode: true)

    begin
      URI.open(url) do |file|
        temp_file.write(file.read)
        temp_file.rewind
      end
      temp_file
    rescue => e
      Rails.logger.error "Failed to download file: #{url} - #{e.message}"
      temp_file.close
      temp_file.unlink
      nil
    end
  end

  def valid_pdf?(url)
    return false if url.blank?

    begin
      file = URI.open(url)
      magic_number = file.read(4) # Read first 4 bytes to check PDF signature
      file.close
      magic_number == "%PDF" # PDFs start with "%PDF"
    rescue => e
      Rails.logger.error "File validation failed: #{url} - #{e.message}"
      false
    end
  end

  def file_exists?(url)
    return false if url.blank?

    begin
      URI.open(url).status[0] == "200" # Check if file is accessible
    rescue => e
      Rails.logger.error "File not found: #{url} - #{e.message}"
      false
    end
  end
end
