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
    ppi             = result[:provider_personal_information]

    render json: {
      provider_attest_id: provider_attest.id,
      caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,
      ppi: ppi.attributes.slice(
        "caqh_provider_attest_id",
        "caqh_provider_id",
        "first_name",
        "middle_name",
        "last_name",
        "address_line1",
        "city",
        "state",
        "zipcode",
        "npi",
        "email_address",
        "date_of_birth"
      )
    }
  end

end
