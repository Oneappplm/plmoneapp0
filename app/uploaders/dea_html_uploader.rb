class DeaHtmlUploader < CarrierWave::Uploader::Base
  if Rails.env.production?
    storage :fog
  else
    storage :file
  end

  def store_dir
    "uploads/dea_webcrawler_log/html/#{model.id}"
  end

  def extension_allowlist
    %w[html]
  end
end