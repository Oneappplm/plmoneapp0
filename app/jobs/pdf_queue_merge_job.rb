# app/jobs/pdf_queue_merge_job.rb
class PdfQueueMergeJob < ApplicationJob
  queue_as :pdf_generation

  def perform(queue_id, provider_id, user_id)
    queue = PdfGenerationQueue.find(queue_id)
    provider = ProviderPersonalInformation.find(provider_id)
    user = User.find(user_id)

    Rails.logger.info "Merging PDFs for queue #{queue.id}"

    # Gather files in order: Verified Profile first
	file_links = []

	# 1️⃣ Verified Profile first
	verified_item = queue.pdf_queue_items.find_by(file_name: "Verified Profile")
	file_links << verified_item.file_path if verified_item&.status == 'completed'

	# 2️⃣ All other files
	other_items = queue.pdf_queue_items.where.not(file_name: "Verified Profile").where(status: 'completed')
	file_links.concat(other_items.pluck(:file_path))

	return if file_links.empty?

	merged_pdf_path = merge_files(file_links, provider)


    # Save to SavedProfile
    queue.create_saved_profile!(
      file_path: File.open(merged_pdf_path), # CarrierWave handles storage
      file_type: 'pdf'
    )

    queue.update!(
	  status: 'completed',
	  generated_date: Time.current,
	  pdf_path: merged_pdf_path,
	  message: 'PDF generated successfully',
	  deleted: true  # <- add this
	)

    provider.update!(
      cred_status: 'psv',
      psv_completed_date: Date.today,
      progress_status: 'to_be_assigned',
      verification_status: 'completed',
      latest_audit_completed_date: Date.today
    )

    Rails.logger.info "Queue #{queue.id} merged successfully -> #{merged_pdf_path}"
  end

  private

  def merge_files(files, provider)
    pdf_dir = Rails.root.join("public/generated_pdfs")
    FileUtils.mkdir_p(pdf_dir)
    filename = "#{provider.caqh_provider_attest_id}_merged_#{Time.current.strftime('%Y%m%d%H%M%S')}.pdf"
    merged_path = pdf_dir.join(filename)

    combined_pdf = CombinePDF.new
    files.each do |file_url|
      path = Rails.root.join('public', file_url.sub(%r{^/}, ''))
      combined_pdf << CombinePDF.load(path) if File.exist?(path)
    end

    combined_pdf.save(merged_path)
    merged_path.to_s
  end
end
