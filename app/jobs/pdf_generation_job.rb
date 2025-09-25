require 'open-uri'
require 'combine_pdf'
require 'fileutils'
require 'wicked_pdf'
require 'mini_magick'

class PdfGenerationJob < ApplicationJob
  queue_as :default

  def perform(queue_id, provider_id, user_id)
    queue    = PdfGenerationQueue.find_by(id: queue_id)
    provider = ProviderPersonalInformation.find_by(id: provider_id)
    user     = User.find_by(id: user_id)

    return Rails.logger.error("PdfGenerationJob: missing queue or provider (queue: #{queue_id}, provider: #{provider_id})") if queue.nil? || provider.nil?

    Rails.logger.info "PdfGenerationJob starting for queue=#{queue.id} provider=#{provider.id}"
    queue.update!(status: 'processing', message: 'Processing PDF generation.')

    begin
      file_links  = []
      item_errors = []

      queue.pdf_queue_items.each do |item|
        begin
          if item.file_name == "Verified Profile"
            pdf_paths = generate_verified_profile_pdfs(provider, user)
            file_links.concat(pdf_paths)
          else
            file_url = item.file_path.to_s
            unless file_exists?(file_url)
              item.update!(status: 'error', message: "File not found: #{file_url}")
              item_errors << "#{item.id}: file not found (#{file_url})"
              next
            end

            if valid_pdf?(file_url)
              file_links << file_url
              item.update!(status: 'sent', message: 'queued for merging')
            elsif image_file?(file_url)
              file_links << file_url
              item.update!(status: 'sent', message: 'queued for image→pdf conversion')
            else
              item.update!(status: 'error', message: "Unsupported file type: #{file_url}")
              item_errors << "#{item.id}: unsupported type (#{file_url})"
              next
            end
          end
        rescue => item_e
          Rails.logger.error "PdfGenerationJob: item processing failed for item=#{item.id} url=#{item.try(:file_path)}: #{item_e.class}: #{item_e.message}"
          item.update!(status: 'error', message: "#{item_e.class}: #{item_e.message}")
          item_errors << "#{item.id}: #{item_e.class}: #{item_e.message}"
          next
        end
      end

      if item_errors.any?
        queue.update!(status: 'error', message: "One or more files failed: #{item_errors.join('; ')}")
        return
      end

      if file_links.empty?
        queue.update!(status: 'error', message: "No valid files to merge for queue #{queue.id}")
        return
      end

      # Merge all into one
      merged_path = generate_pdf(file_links, provider, queue)

      queue.pdf_queue_items.update_all(status: 'completed', message: 'completed')
      queue.update!(status: 'completed', generated_date: Time.current, pdf_path: merged_path, message: 'PDF generated successfully')

      # Optionally mark for deletion later
      queue.update!(deleted: true)

      Rails.logger.info "PdfGenerationJob completed for queue=#{queue.id} -> #{merged_path}"
    rescue => e
      Rails.logger.error "PdfGenerationJob FAILED for queue=#{queue.id}: #{e.class}: #{e.message}"
      queue.update!(status: 'error', message: "#{e.class}: #{e.message}")
    end
  end

  private

  def image_file?(url)
    ext = File.extname(url.to_s).downcase
    %w[.jpg .jpeg .png .gif .tiff].include?(ext)
  end

  # Generate Verified Profile PDFs and return RELATIVE paths
  def generate_verified_profile_pdfs(provider, user)
    [
      render_pdf('mhc/verification_platform/verified_profile_pdf', provider, 'verified_profile', user)
    ]
  end

  # Render template into PDF and return relative path under /public
  def render_pdf(template, provider, filename_prefix, user)
    pdf_dir = Rails.root.join("public/generated_pdfs")
    FileUtils.mkdir_p(pdf_dir)

    filename = "#{provider.caqh_provider_attest_id}_#{filename_prefix}_#{Time.current.strftime('%Y%m%d%H%M%S')}.pdf"
    pdf_path = pdf_dir.join(filename)

    provider_oig_tab_details = provider.rva_informations.where(tab: 'OIG').where(status: 'completed').where.not(source_date: nil)
    provider_npdb_tab_details = provider.rva_informations.where(tab: 'NPDB')
    grouped_disclosures = provider.provider_disclosures
                                  .where(disclosure_answer_flag: true)
                                  .where.not(disclosure_explanation: [nil, ""])
                                  .group_by { |d| QUESTIONS_DISCLOSURE.find { |_h, qs| qs.include?(d.disclosure_question_disclosure_summary) }&.first }

    html_content = ApplicationController.render(
      template: template,
      layout: 'pdf',
      locals: {
        provider_personal_information: provider,
        oig_details: provider_oig_tab_details,
        npdb_details: provider_npdb_tab_details,
        user: user,
        grouped_disclosures: grouped_disclosures
      }
    )

    pdf_file = WickedPdf.new.pdf_from_string(html_content)
    File.open(pdf_path, 'wb') { |file| file.write(pdf_file) }

    "/generated_pdfs/#{filename}"  # return relative path
  rescue => e
    Rails.logger.error "render_pdf failed for provider=#{provider.id}: #{e.class}: #{e.message}"
    raise
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
          if valid_pdf?(file_url)
            combined_pdf << CombinePDF.load(temp_file.path)
          else
            Rails.logger.info "Converting image to PDF: #{file_url}"
            img_pdf = image_to_pdf(temp_file)
            combined_pdf << img_pdf
          end
        ensure
          temp_file.close
          temp_file.unlink
        end
      else
        Rails.logger.warn "generate_pdf: skipping missing file #{file_url}"
      end
    end

    combined_pdf.save(merged_pdf_path.to_s)

    queue.create_saved_profile!(
      file_path: File.open(merged_pdf_path), # CarrierWave will copy/store it
      file_type: 'pdf'
    )

    provider.update!(cred_status: 'psv', psv_completed_date: Date.today, progress_status: 'to_be_assigned', verification_status: 'completed')

    merged_pdf_path.to_s
  end

  def download_file(url)
    return nil if url.blank?

    if url.start_with?('/')
      local_path = Rails.root.join('public', url.sub(%r{^/}, ''))
      return nil unless File.exist?(local_path)

      temp_file = Tempfile.new(['downloaded', '.pdf'], binmode: true)
      File.open(local_path, 'rb') { |f| temp_file.write(f.read) }
      temp_file.rewind
      temp_file
    else
      temp_file = Tempfile.new(['downloaded', '.pdf'], binmode: true)
      begin
        URI.open(url, read_timeout: 10) do |remote|
          temp_file.write(remote.read)
          temp_file.rewind
        end
        temp_file
      rescue => e
        Rails.logger.error "download_file failed for #{url}: #{e.class}: #{e.message}"
        temp_file.close
        temp_file.unlink
        nil
      end
    end
  end

  def valid_pdf?(url)
    return false if url.blank?
    begin
      if url.start_with?('/')
        local_path = Rails.root.join('public', url.sub(%r{^/}, ''))
        return false unless File.exist?(local_path)
        File.open(local_path, 'rb') { |f| f.read(4).start_with?('%PDF') }
      else
        URI.open(url, read_timeout: 5) do |f|
          magic = f.read(4)
          magic && magic.start_with?('%PDF')
        end
      end
    rescue
      false
    end
  end

  def file_exists?(url)
    return false if url.blank?
    if url.start_with?('/')
      local_path = Rails.root.join('public', url.sub(%r{^/}, ''))
      File.exist?(local_path)
    else
      URI.open(url, read_timeout: 5) { |f| f.status[0] == "200" }
    end
  rescue
    false
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
