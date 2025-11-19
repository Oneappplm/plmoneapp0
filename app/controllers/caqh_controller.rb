class CaqhController < ApplicationController
  protect_from_forgery with: :null_session

  def show
  end

  def upload
    Caqh::ImportService.call(params)
  end

  # NEW PDF upload — CALLS ProviderImporter DIRECTLY
  def upload_pdf
    pdf_files = params.values.select { |v| v.is_a?(ActionDispatch::Http::UploadedFile) }

    raise "No PDF uploaded" if pdf_files.empty?

    imported_records = []

    pdf_files.each do |uploaded_pdf|
      # Save temporarily
      tmp_path = Rails.root.join("tmp", uploaded_pdf.original_filename)
      File.open(tmp_path, "wb") { |f| f.write(uploaded_pdf.read) }

      # This is exactly what you did in Rails console:
      importer = Caqh::ProviderImporter.new(tmp_path)
      ppi      = importer.call

      imported_records << {
        provider_attest_id: ppi.provider_attest_id,
        caqh_provider_id:   ppi.caqh_provider_id,
        name:               "#{ppi.first_name} #{ppi.last_name}"
      }

      # cleanup
      File.delete(tmp_path) if File.exist?(tmp_path)
    end

    render json: { status: "pdf_imported", providers: imported_records }
  end
end
