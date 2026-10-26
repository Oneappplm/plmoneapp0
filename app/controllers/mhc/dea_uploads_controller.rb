class Mhc::DeaUploadsController < ApplicationController
  protect_from_forgery with: :exception

  def presign
    filename = params[:filename].to_s

    unless filename.downcase.end_with?(".txt")
      return render json: { error: "Only DEA .txt files are allowed." },
                    status: :unprocessable_entity
    end

    content_type = params[:content_type].presence || "application/octet-stream"
    obj_key = build_key(filename)

    presigned = DeaStorage.resource
                          .bucket(DeaStorage.bucket)
                          .object(obj_key)
                          .presigned_url(
                            :put,
                            expires_in: 1800,
                            content_type: content_type
                          )

    render json: {
      url: presigned,
      key: obj_key
    }
  rescue StandardError => e
    Rails.logger.error("[DEA UPLOAD] presign failed: #{e.class} #{e.message}")

    render json: { error: "Unable to prepare DEA upload." },
           status: :internal_server_error
  end

  private

  def build_key(filename)
    safe_name = filename.to_s.gsub(/[^a-zA-Z0-9.\-_]/, "_")
    "dea_imports/#{Time.current.strftime('%Y/%m/%d')}/#{SecureRandom.uuid}-#{safe_name}"
  end
end