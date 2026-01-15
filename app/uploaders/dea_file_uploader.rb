# app/uploaders/dea_file_uploader.rb
class DeaFileUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "uploads/dea_imports/#{model.id}"
  end

  def extension_allowlist
    %w[txt csv]
  end
end
