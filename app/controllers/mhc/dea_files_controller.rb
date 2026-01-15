# app/controllers/mhc/dea_files_controller.rb
class Mhc::DeaFilesController < ApplicationController
  DEA_TMP_DIR = Rails.root.join("tmp", "dea_uploads")

  def new; end

  def create
    if params[:dea_file].blank?
      redirect_to new_mhc_dea_file_path, alert: "Please select a file."
      return
    end

    uploaded_file = params[:dea_file]
    FileUtils.mkdir_p(DEA_TMP_DIR)

    # (Optional) cleanup old files (safe + cheap)
    cleanup_old_files!(DEA_TMP_DIR, older_than: 2.days)

    filename = "dea_#{SecureRandom.hex(8)}_#{uploaded_file.original_filename}"
    filepath = DEA_TMP_DIR.join(filename)

    # Stream copy instead of uploaded_file.read (less memory for large files)
    File.open(filepath, "wb") do |f|
      IO.copy_stream(uploaded_file.tempfile, f)
    end

    job = WeeklyDeaImportJob.perform_later(filepath.to_s)

    redirect_to new_mhc_dea_file_path(job_id: job.job_id), notice: "DEA import started."
  end

  private

  def cleanup_old_files!(dir, older_than:)
    Dir.glob(dir.join("dea_*")).each do |path|
      begin
        File.delete(path) if File.file?(path) && File.mtime(path) < Time.current - older_than
      rescue => e
        Rails.logger.warn("DEA cleanup failed for #{path}: #{e.message}")
      end
    end
  end
end
