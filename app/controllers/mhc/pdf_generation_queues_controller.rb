class Mhc::PdfGenerationQueuesController < ApplicationController
  before_action :set_queue, only: [:pause, :destroy, :requeue]

  def create
    provider_id = params[:selected_files][0][:provider_id]
    selected_links = params[:selected_files] || []
    uploaded_file = params[:file] 

    provider = ProviderPersonalInformation.find(provider_id)
    return render json: { error: "Provider not found" }, status: :unprocessable_entity unless provider

    queue = provider.pdf_generation_queues.create!(
      status: "queued",
      queued_date: Time.current,
      message: "Processing started",
      user_id: current_user.id
    )

    # Add queue items
    if selected_links.any? { |link| link["file_name"] == "Verified Profile" }
      queue.pdf_queue_items.create!(file_name: "Verified Profile", file_path: "verified_profile", status: "queued")
    end

    selected_links.each do |link|
      next if link["file_name"] == "Verified Profile"
      queue.pdf_queue_items.create!(file_name: File.basename(link['file_url']), file_path: link['file_url'], status: "queued")
    end

    if uploaded_file.present?
      file_path = Rails.root.join("public/uploads", uploaded_file.original_filename)
      File.open(file_path, "wb") { |f| f.write(uploaded_file.read) }
      queue.pdf_queue_items.create!(file_name: uploaded_file.original_filename, file_path: "/uploads/#{uploaded_file.original_filename}", status: "queued")
    end

    # Enqueue each item separately
    queue.pdf_queue_items.find_each do |item|
      PdfQueueItemJob.perform_later(item.id, provider.id, current_user.id)
    end

    render json: { message: "Your request is queued", queue_number: queue.id, queue_status: queue.status }
  end

  # delete saved profile
  def delete_saved_profile
    if params[:selected_profiles].present?
      selected_psvs = params[:selected_profiles].split(',')
      selected_profiles = SavedProfile.where(id: selected_psvs)

      selected_profiles.destroy_all
      redirect_to profile_page_path(provider_personal_info: params[:personalInfoId]), notice: 'Selected PSV deleted successfully.'
    else
      redirect_to profile_page_path(provider_personal_info: params[:personalInfoId]), alert: 'No PSV selected for deletion.'
    end
  end

  # Pause Job
  def pause
    if @queue.update(status: "Paused")
      render json: { success: true, message: "Queue paused successfully." }
    else
      render json: { success: false, message: "Failed to pause the queue." }, status: :unprocessable_entity
    end
  end

  # Delete Queue
  def destroy
    if @queue.destroy
      redirect_to profile_page_path(provider_personal_info: params[:provider_personal_information]), notice: 'Queue deleted successfully.'
    else
      redirect_to profile_page_path(provider_personal_info: params[:provider_personal_information]), alert: 'Failed to delete the queue.'
    end
  end


  # Requeue Job
  def requeue
    new_queue = PdfGenerationQueue.create(status: "Queued", source_file: @queue.source_file, message: "Requeued")
    if new_queue.persisted?
      render json: { success: true, message: "Queue requeued successfully.", new_queue_id: new_queue.id }
    else
      render json: { success: false, message: "Failed to requeue the queue." }, status: :unprocessable_entity
    end
  end

  def queue_items
    queue_items = PdfQueueItem.where(pdf_generation_queue_id: params[:id])
    render json: queue_items
  end

  private

  def set_queue
    @queue = PdfGenerationQueue.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, message: "Queue not found." }, status: :not_found
  end
end
