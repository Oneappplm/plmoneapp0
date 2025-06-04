require 'open-uri'
require 'combine_pdf'
require 'fileutils'
require 'wicked_pdf'

class PdfGenerationJob < ApplicationJob
  queue_as :default

  def perform(queue_id, provider)
    queue = PdfGenerationQueue.find_by(id: queue_id)
    return if queue.nil?

    sleep(2)
    queue.pdf_queue_items.update_all(status: 'sent')
    queue.update!(status: 'sent', message: 'Processing PDF generation.')

    begin
      file_links = []

      queue.pdf_queue_items.each do |item|
        if item.file_name == "Verified Profile"
          # Generate PDF from the HTML pages
          pdf_paths = generate_verified_profile_pdfs(provider)
          file_links.concat(pdf_paths)
        else
          file_url = item.file_path
          if !file_exists?(file_url)
            item.update!(status: 'error', message: 'File not found.')
          elsif !valid_pdf?(file_url)
            item.update!(status: 'error', message: 'File not a valid PDF.')
          else
            file_links << file_url
          end
        end
      end

      if queue.pdf_queue_items.where(status: 'error').exists?
        queue.update!(status: 'error', message: 'One or more files are invalid or missing.')
        return
      end

      pdf_path = generate_pdf(file_links, provider, queue)

      sleep(2)
      queue.pdf_queue_items.update_all(status: 'completed')
      queue.update!(status: 'completed', generated_date: Time.current, pdf_path: pdf_path)

      sleep(5)
      queue.update!(deleted: true)

    rescue => e
      sleep(2)
      queue.update!(status: 'error', message: 'Something went wrong.')
    end
  end

  private

  def generate_verified_profile_pdfs(provider)
    provider_personal_information = provider
    pdf_dir = Rails.root.join("public/generated_pdfs")
    FileUtils.mkdir_p(pdf_dir)

    # Generate PDFs for both templates
    pdf_paths = [
      render_pdf('mhc/verification_platform/verified_profile_pdf', provider, 'verified_profile')
    ]

    pdf_paths
  end

  def render_pdf(template, provider, filename_prefix)

    oig_details = provider.rva_informations.where(tab: 'OIG')
    dea_details = provider.rva_informations.where(tab: 'Registration')
    pdf_dir = Rails.root.join("public/generated_pdfs")
    FileUtils.mkdir_p(pdf_dir)

    filename = "#{provider.caqh_provider_attest_id}_#{filename_prefix}_#{Time.current.strftime('%Y%m%d%H%M%S')}.pdf"
    pdf_path = pdf_dir.join(filename)

    html_content = ApplicationController.render(
      template: template,
      layout: 'pdf',
      locals: { provider_personal_information: provider, oig_details: oig_details,  dea_details: dea_details}
    )

    pdf_file = WickedPdf.new.pdf_from_string(html_content)

    File.open(pdf_path, 'wb') { |file| file.write(pdf_file) }
    pdf_path.to_s
  end

  def generate_pdf(files, provider, queue)
    pdf_dir = Rails.root.join("public/generated_pdfs")
    FileUtils.mkdir_p(pdf_dir)

    filename = "#{provider.caqh_provider_attest_id}_#{SecureRandom.hex(5)}_#{Time.current.strftime('%Y%m%d%H%M%S')}.pdf"
    merged_pdf_path = pdf_dir.join(filename)

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

    combined_pdf.save(merged_pdf_path)

    saved_profile = queue.create_saved_profile!(
      file_path: merged_pdf_path.to_s,
      file_type: 'pdf'
    )
    provider.update(cred_status: 'psv')
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
      magic_number == "%PDF"
    rescue => e
      Rails.logger.error "File validation failed: #{url} - #{e.message}"
      false
    end
  end

  def file_exists?(url)
    return false if url.blank?

    begin
      URI.open(url).status[0] == "200"
    rescue => e
      Rails.logger.error "File not found: #{url} - #{e.message}"
      false
    end
  end
end
