class Admin::UploadsController < ApplicationController
  UPLOAD_PATH = Rails.env.production? ? "/data/uploads" : Rails.root.join("storage", "uploads")

  def index
    Dir.mkdir(UPLOAD_PATH) unless Dir.exist?(UPLOAD_PATH)
    @files = Dir.children(UPLOAD_PATH).select { |f| File.file?(File.join(UPLOAD_PATH, f)) }
  end

  def create
    uploaded_file = params[:file]
    if uploaded_file.present?
      Dir.mkdir(UPLOAD_PATH) unless Dir.exist?(UPLOAD_PATH)
      File.open(File.join(UPLOAD_PATH, uploaded_file.original_filename), "wb") do |file|
        file.write(uploaded_file.read)
      end
      redirect_to admin_uploads_path, notice: "File uploaded successfully."
    else
      redirect_to admin_uploads_path, alert: "Please choose a file to upload."
    end
  end

  def download
    file_path = "/data/uploads/#{params[:filename]}"
    if File.exist?(file_path)
      send_file file_path, filename: params[:filename], disposition: :attachment
    else
      redirect_to admin_uploads_path, alert: "File not found."
    end
  end
end
