# frozen_string_literal: true

class SsaVerificationPdfUploader < CarrierWave::Uploader::Base
  storage Rails.env.production? ? :fog : :file

  def store_dir
    "uploads/ssa_verifications/#{model.id}"
  end

  def extension_allowlist
    %w[pdf]
  end

  def content_type_allowlist
    ["application/pdf"]
  end

  def filename
    "ssa_verification_#{model.id}.pdf"
  end
end