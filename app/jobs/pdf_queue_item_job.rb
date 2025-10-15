# app/jobs/pdf_queue_item_job.rb
class PdfQueueItemJob < ApplicationJob
  queue_as :pdf_generation

  def perform(item_id, provider_id, user_id)
    item = PdfQueueItem.find(item_id)
    provider = ProviderPersonalInformation.find(provider_id)
    user = User.find(user_id)

    Rails.logger.info "Processing PdfQueueItem #{item.id} for queue #{item.pdf_generation_queue.id}"

    if item.file_name == "Verified Profile"
      pdf_path = render_verified_profile_pdf(provider, user)
      item.update!(status: 'completed', file_path: pdf_path, message: 'Verified Profile PDF generated')
    else
      # validate and mark item
      if File.exist?(Rails.root.join('public', item.file_path.sub(%r{^/}, '')))
        item.update!(status: 'completed', message: 'File ready for merge')
      else
        item.update!(status: 'error', message: 'File missing')
      end
    end

    # Trigger merge if all items done
    queue = item.pdf_generation_queue
    queue.with_lock do
	  if queue.pdf_queue_items.where.not(status: 'completed').count == 0 && !queue.merge_enqueued?
	    queue.update!(merge_enqueued: true)
	    PdfQueueMergeJob.perform_later(queue.id, provider.id, user.id)
	  end
	end
  rescue => e
    Rails.logger.error "PdfQueueItemJob FAILED for item #{item.id}: #{e.class} #{e.message}"
    item.update!(status: 'error', message: e.message)
  end

  private

  def render_verified_profile_pdf(provider, user)
    pdf_dir = Rails.root.join("public/generated_pdfs")
    FileUtils.mkdir_p(pdf_dir)
    filename = "#{provider.caqh_provider_attest_id}_verified_profile_#{Time.current.strftime('%Y%m%d%H%M%S')}.pdf"
    pdf_path = pdf_dir.join(filename)

    html_content = ApplicationController.render(
	  template: 'mhc/verification_platform/verified_profile_pdf',
	  layout: 'pdf',
	  locals: {
	    provider_personal_information: provider,
	    user: user,
	    oig_details: provider.rva_informations.where(tab: 'OIG').where(status: 'completed').where.not(source_date: nil),
	    npdb_details: provider.rva_informations.where(tab: 'NPDB'),
	    grouped_disclosures: provider.provider_disclosures
	                          .where(disclosure_answer_flag: true)
	                          .where.not(disclosure_explanation: [nil, ""])
	                          .group_by { |d| QUESTIONS_DISCLOSURE.find { |_h, qs| qs.include?(d.disclosure_question_disclosure_summary) }&.first }
	  }
	)

    pdf_file = WickedPdf.new.pdf_from_string(html_content)
    File.open(pdf_path, 'wb') { |f| f.write(pdf_file) }

    "/generated_pdfs/#{filename}"
  end
end
