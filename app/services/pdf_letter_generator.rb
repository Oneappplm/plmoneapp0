require "combine_pdf"
require "wicked_pdf"
require "mini_magick"
require "base64"
require "securerandom"
require "open-uri"
require "tempfile"

class PdfLetterGenerator
  MISSING_RELEASE_HTML = "<p class='alert alert-danger'>
    The Release file might be missing. Please upload it and try again.
  </p>"

  def initialize(practice_education)
    @education = practice_education
    @ppi = ProviderPersonalInformation.find_by(provider_attest_id: @education.provider_attest.id)
    raise ArgumentError, "Provider personal information not found" unless @ppi
  end

  def generate_preview!
    Rails.logger.info("🔹 [PDF] Generating preview for #{@ppi.full_name}")

    # STEP 1: Get latest release file
    release_doc = @ppi.provider_personal_uploaded_docs
                      .where("LOWER(image_classification) = ?", "release")
                      .order(created_at: :desc)
                      .first
    raise StandardError, MISSING_RELEASE_HTML unless release_doc&.file_upload.present?

    release_path = fetch_release_file_path(release_doc)
    raise StandardError, "Release file not found after fetch" unless File.exist?(release_path)

    # STEP 2: Convert release → PDF (if TIFF)
    ext = File.extname(release_path).downcase
    release_pdf_binary =
      if ext == ".pdf"
        File.binread(release_path)
      elsif %w[.tif .tiff].include?(ext)
        convert_tiff_to_pdf_with_header_footer(release_path)
      else
        raise StandardError, "<p class='alert alert-danger'>
          Only PDF or TIFF release files are allowed.
        </p>"
      end

    # STEP 3: Render header/footer + letter
    header_html = ApplicationController.render(template: "pdf_templates/shared/header", layout: false)
    footer_html = ApplicationController.render(template: "pdf_templates/shared/footer", layout: false)
    letter_html_body = ApplicationController.render(
      template: "pdf_templates/education_letter",
      layout: false,
      assigns: { ppi: @ppi, education: @education }
    )

    # Inject inline CSS and structure
    letter_html = <<-HTML
      <html>
        <head>
          <meta charset="UTF-8">
          <style>
            #{custom_pdf_styles}
          </style>
        </head>
        <body>
          <div class="header">#{header_html}</div>
          <div class="page">
            #{letter_html_body}
          </div>
          <div class="footer">#{footer_html}</div>
        </body>
      </html>
    HTML

    letter_pdf_binary = WickedPdf.new.pdf_from_string(
      letter_html,
      margin: { top: 0, bottom: 0, left: 15, right: 15 },
      page_size: 'A3',           # 👈 Bigger than default A4
      zoom: 1.2,                 # 👈 Optional: makes everything slightly larger
    )

    # STEP 4: Merge both — letter first, then release pages
    combined = CombinePDF.new
    combined << CombinePDF.parse(letter_pdf_binary)
    combined << CombinePDF.parse(release_pdf_binary)

    combined.to_pdf
  rescue => e
    Rails.logger.error("❌ [PDF ERROR] #{e.class}: #{e.message}\n#{e.backtrace.take(5).join("\n")}")
    raise StandardError, "<p class='alert alert-danger'>
      The Release file generation failed. Please upload a valid PDF/TIFF file.
    </p>"
  end

  private

  def fetch_release_file_path(release_doc)
    local_path = release_doc.file_upload.try(:path)
    return local_path if local_path && File.exist?(local_path)

    ext = File.extname(release_doc.file_upload.filename.to_s)
    tmp = Tempfile.new(["release_", ext])
    URI.open(release_doc.file_upload.url) { |f| IO.copy_stream(f, tmp) }
    tmp.close
    tmp.path
  end

  def convert_tiff_to_pdf_with_header_footer(tiff_path)
    raise StandardError, "TIFF not found: #{tiff_path}" unless File.exist?(tiff_path)

    pdf_pages = CombinePDF.new

    frame_count = MiniMagick::Tool.new("identify") do |identify|
      identify.format("%n")
      identify << tiff_path
    end.to_i
    frame_count = 1 if frame_count.zero?

    Rails.logger.info("🖼️ TIFF has #{frame_count} page(s)")

    header_html = ApplicationController.render(template: "pdf_templates/shared/header", layout: false)
    footer_html = ApplicationController.render(template: "pdf_templates/shared/footer", layout: false)

    frame_count.times do |i|
      tmp_png = Rails.root.join("tmp", "tiff_frame_#{SecureRandom.hex(6)}.png")

      MiniMagick::Tool.new("convert") do |convert|
        convert << "#{tiff_path}[#{i}]"
        convert << tmp_png.to_s
      end

      base64_png = Base64.strict_encode64(File.binread(tmp_png))

      html = <<-HTML
        <html>
          <head>
            <meta charset="UTF-8">
            <style>
              #{custom_pdf_styles}
            </style>
          </head>
          <body>
            <div class="header">#{header_html}</div>
            <div class="page">
              <div class="content">
                <img src="data:image/png;base64,#{base64_png}" />
              </div>
            </div>
            <div class="footer">#{footer_html}</div>
          </body>
        </html>
      HTML

      page_pdf_binary = WickedPdf.new.pdf_from_string(
        html,
        margin: { top: 0, bottom: 0, left: 15, right: 15 },
        page_size: 'A3',           # 👈 Bigger than default A4
        zoom: 1.2,                 # 👈 Optional: makes everything slightly larger
      )

      pdf_pages << CombinePDF.parse(page_pdf_binary)
    ensure
      File.delete(tmp_png) if File.exist?(tmp_png)
    end

    pdf_pages.to_pdf
  end

  # ✅ Centralized CSS styles for all pages
  def custom_pdf_styles
    <<-CSS
      body {
        margin: 0;
        font-family: 'Liberation Serif', 'Times New Roman', serif;
        font-size: 13px;
        color: #000;
        line-height: 1.5;
      }

      .page {
        position: relative;
        width: 100%;
        min-height: 100vh;
        padding-top: 110px;
        padding-bottom: 80px;
      }

      .header, .footer {
        position: fixed;
        left: 0;
        right: 0;
        width: 100%;
        text-align: center;
      }

      .header {
        top: 20;
        padding-bottom: 5px;
      }

      /*.footer {
        bottom: 0;
        padding-top: 5px;
        font-size: 11px;
        color: #555;
      }*/

      .content img {
        width: 100%;
        height: auto;
        display: block;
        margin:0 auto;
      }

      h1, h2, h3 {
        font-family: 'Liberation Serif', serif;
        color: #222;
      }

      table {
        width: 100%;
        border-collapse: collapse;
      }

      td, th {
        padding: 5px;
        vertical-align: top;
      }

      .logo {
        max-width: 180px;
      }
    CSS
  end
end
