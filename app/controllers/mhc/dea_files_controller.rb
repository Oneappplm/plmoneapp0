class Mhc::DeaFilesController < ApplicationController
  def new
  end

  def create
    if params[:dea_file].blank?
      redirect_to new_mhc_dea_file_path, alert: "Please select a file."
      return
    end

    uploaded_file = params[:dea_file]

    # 1 — remove previous DEA files
    Dir.glob(Rails.root.join("tmp", "dea_*")).each do |old_file|
      File.delete(old_file) if File.exist?(old_file)
    end

    # 2 — save uploaded file
    filename = "dea_#{Time.now.to_i}_#{uploaded_file.original_filename}"
    filepath = Rails.root.join("tmp", filename)

    File.binwrite(filepath, uploaded_file.read)

    # 3 — enqueue job
    job = WeeklyDeaImportJob.perform_later(filepath.to_s)

    # 4 — CORRECT redirect helper
    redirect_to new_mhc_dea_file_path(job_id: job.job_id), notice: "DEA import started."
  end
end
