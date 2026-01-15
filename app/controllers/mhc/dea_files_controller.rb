class Mhc::DeaFilesController < ApplicationController
  def new
  end

  def create
    uploaded_file = params[:dea_file]

    unless uploaded_file
      redirect_to new_mhc_dea_file_path, alert: "Please select a file"
      return
    end

    # optional safety check
    if uploaded_file.size > 1000.megabytes
      redirect_to new_mhc_dea_file_path, alert: "File too large"
      return
    end

    storage_dir = Rails.root.join("storage", "dea_imports")
    FileUtils.mkdir_p(storage_dir)

    # ✅ replace existing DEA file
    Dir.glob(storage_dir.join("dea_*")).each do |old_file|
      File.delete(old_file) if File.exist?(old_file)
    end

    filename = "dea_#{Time.now.to_i}_#{uploaded_file.original_filename}"
    filepath = storage_dir.join(filename)

    # ✅ stream upload
    File.open(filepath, "wb") do |f|
      IO.copy_stream(uploaded_file.tempfile, f)
    end

    job = WeeklyDeaImportJob.perform_later(filepath.to_s)

    redirect_to new_mhc_dea_file_path(job_id: job.job_id),
                notice: "DEA import started."
  end
end
