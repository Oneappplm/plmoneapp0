class CaqhController < ApplicationController
  protect_from_forgery with: :null_session

  def show
  end

  def upload
    Caqh::ImportService.call(params)
  end

  # NEW PDF upload — CALLS ProviderImporter DIRECTLY
  def upload_pdf
    uploaded = params.values.find { |v| v.is_a?(ActionDispatch::Http::UploadedFile) }

    tmp_path = Rails.root.join("tmp", uploaded.original_filename)
    FileUtils.cp(uploaded.tempfile.path, tmp_path)

    result = Caqh::ProviderImporter.new(tmp_path).call

    provider_attest = result[:provider_attest]

    render json: {
      redirect_url: mhc_verification_platform_path(provider_attest.id)
    }
  end

end
