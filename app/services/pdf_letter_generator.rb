require "combine_pdf"
require "wicked_pdf"
require "mini_magick"
require "base64"
require "securerandom"
require "open-uri"
require "tempfile"
require "tmpdir"
require "fileutils"

class PdfLetterGenerator
  MISSING_RELEASE_HTML = "<p class='alert alert-danger'>
    The Release file might be missing. Please upload it and try again.
  </p>"

  def initialize(record, template: "pdf_templates/education_letter", assign_name: :education, release_sub_section: nil, header_template: "pdf_templates/shared/header", footer_template: "pdf_templates/shared/footer", authorization_image: nil, include_uploaded_release: true, extra_templates: [])
    @record = record
    @template = template
    @assign_name = assign_name
    @release_sub_section = release_sub_section
    @header_template = header_template
    @footer_template = footer_template
    @authorization_image = authorization_image
    @include_uploaded_release = include_uploaded_release
    @extra_templates = extra_templates

    provider_attest_id = if @record.respond_to?(:provider_attest_id)
      @record.provider_attest_id
    elsif @record.respond_to?(:provider_attest)
      @record.provider_attest&.id
    end

    @ppi = ProviderPersonalInformation.find_by(provider_attest_id: provider_attest_id)

    raise ArgumentError, "Provider personal information not found" unless @ppi
  end

  def generate_preview!
    Rails.logger.info("🔹 [PDF] Generating preview for #{@ppi.full_name}")

    release_pdf_binary = nil

    # STEP 1: Get uploaded Release file only when required
    if @include_uploaded_release
      release_doc = find_release_doc

      raise StandardError, MISSING_RELEASE_HTML unless release_doc.present?

      release_url = release_doc.file_upload&.url.to_s
      release_path = release_doc.file_upload&.path.to_s

      if release_url.blank? && release_path.blank?
        raise StandardError, MISSING_RELEASE_HTML
      end

      Rails.logger.info(
        "📄 [PDF] Using release doc ID=#{release_doc.id}, " \
        "sub_section=#{release_doc.sub_section.inspect}, " \
        "url=#{release_url.inspect}, " \
        "path=#{release_path.inspect}"
      )

      release_path = fetch_release_file_path(release_doc)

      unless release_path.present? && File.exist?(release_path)
        raise StandardError, "Release file not found after fetch"
      end

      ext = File.extname(release_path).downcase

      if ext.blank?
        upload_url = release_doc.file_upload.url.to_s

        begin
          ext = File.extname(URI.parse(upload_url).path).downcase
        rescue URI::InvalidURIError
          ext = File.extname(upload_url).downcase
        end
      end

      release_pdf_binary = if ext == ".pdf"
        File.binread(release_path)
      elsif %w[.tif .tiff].include?(ext)
        convert_tiff_to_pdf_with_header_footer(release_path)
      else
        raise StandardError, "<p class='alert alert-danger'>
          Only PDF or TIFF release files are allowed.
        </p>"
      end
    end

    # STEP 2: Render common header/footer
    header_html = ApplicationController.render(template: @header_template, layout: false)
    footer_html = ApplicationController.render(template: @footer_template, layout: false)

    # STEP 3: Render main verification letter
    letter_html_body = ApplicationController.render(
      template: @template,
      layout: false,
      assigns: {
        ppi: @ppi,
        @assign_name => @record
      }
    )

    letter_html = <<-HTML
      <html>
        <head>
          <meta charset="UTF-8">
          <style>
            #{custom_pdf_styles}
          </style>
        </head>

        <body>
          <div class="header">
            #{header_html}
          </div>

          <div class="page">
            #{letter_html_body}
          </div>

          <div class="footer">
            #{footer_html}
          </div>
        </body>
      </html>
    HTML

    letter_pdf_binary = WickedPdf.new.pdf_from_string(
      letter_html,
      margin: {
        top: 0,
        bottom: 0,
        left: 12,
        right: 12
      },
      page_size: "Letter",
      zoom: 1.0
    )

    extra_pdf_binaries = []

    @extra_templates.each do |extra_template|
      extra_html_body = ApplicationController.render(
        template: extra_template,
        layout: false,
        assigns: {
          ppi: @ppi,
          @assign_name => @record
        }
      )

      extra_html = <<-HTML
        <html>
          <head>
            <meta charset="UTF-8">
            <style>
              #{custom_pdf_styles}
            </style>
          </head>

          <body>
            <div class="header">
              #{header_html}
            </div>

            <div class="page">
              #{extra_html_body}
            </div>

            <div class="footer">
              #{footer_html}
            </div>
          </body>
        </html>
      HTML

      extra_pdf_binary = WickedPdf.new.pdf_from_string(
        extra_html,
        margin: {
          top: 0,
          bottom: 0,
          left: 12,
          right: 12
        },
        page_size: "Letter",
        zoom: 1.0
      )

      extra_pdf_binaries << extra_pdf_binary
    end

    # STEP 4: Render Standard Authorization page when configured
    authorization_pdf_binary = nil

    if @authorization_image.present?
      authorization_html = <<-HTML
        <html>
          <head>
            <meta charset="UTF-8">

            <style>
              #{custom_pdf_styles}

              .authorization-page {
                position: relative;
                width: 100%;
                padding-top: 70px;
                padding-bottom: 60px;
                box-sizing: border-box;
              }

              .authorization-image-wrapper {
                width: 100%;
                text-align: center;
              }

              .authorization-image-wrapper img {
                display: block;
                width: 100%;
                height: auto;
                max-width: 100%;
                margin: 0 auto;
              }
            </style>
          </head>

          <body>
            <div class="header">
              #{header_html}
            </div>

            <div class="authorization-page">
              <div class="authorization-image-wrapper">
                <img src="#{ApplicationController.helpers.wicked_pdf_asset_base64(@authorization_image)}" />
              </div>
            </div>

            <div class="footer">
              #{footer_html}
            </div>
          </body>
        </html>
      HTML

      authorization_pdf_binary = WickedPdf.new.pdf_from_string(
        authorization_html,
        margin: {
          top: 0,
          bottom: 0,
          left: 12,
          right: 12
        },
        page_size: "Letter",
        zoom: 1.0
      )
    end

    # STEP 5: Merge pages
    combined = CombinePDF.new

    # Page 1
    combined << CombinePDF.parse(letter_pdf_binary)

    # Page 2 / Page 3 generated templates
    extra_pdf_binaries.each do |pdf_binary|
      combined << CombinePDF.parse(pdf_binary)
    end

    # Final image page
    if authorization_pdf_binary.present?
      combined << CombinePDF.parse(authorization_pdf_binary)
    end

    # Legacy uploaded release, only where still required
    if @include_uploaded_release && release_pdf_binary.present?
      combined << CombinePDF.parse(release_pdf_binary)
    end

    combined.to_pdf
  rescue => e
    Rails.logger.error(
      "❌ [PDF ERROR] #{e.class}: #{e.message}\n" \
      "#{e.backtrace.take(10).join("\n")}"
    )

    raise StandardError, "<p class='alert alert-danger'>
      The verification letter generation failed. Please try again.
    </p>"
  end

  private

  def fetch_release_file_path(release_doc)
    local_path = release_doc.file_upload.try(:path)
    return local_path if local_path.present? && File.exist?(local_path)

    upload_url = release_doc.file_upload.url.to_s

    raise StandardError, "Release file URL is missing" if upload_url.blank?

    ext = File.extname(release_doc.file_upload.filename.to_s).downcase

    if ext.blank?
      begin
        ext = File.extname(URI.parse(upload_url).path).downcase
      rescue URI::InvalidURIError
        ext = File.extname(upload_url).downcase
      end
    end

    unless [".pdf", ".tif", ".tiff"].include?(ext)
      raise StandardError, "Unsupported Release file type: #{ext.presence || 'unknown'}"
    end

    tmp = Tempfile.new(["release_", ext])
    tmp.binmode

    if upload_url.start_with?("/")
      absolute_path = Rails.root.join("public", upload_url.delete_prefix("/"))

      raise StandardError, "Release file not found: #{absolute_path}" unless File.exist?(absolute_path)

      File.open(absolute_path, "rb") do |file|
        IO.copy_stream(file, tmp)
      end
    else
      URI.open(upload_url, "rb") do |file|
        IO.copy_stream(file, tmp)
      end
    end

    tmp.flush
    tmp.close

    tmp.path
  end

  def find_release_doc
    release_scope = @ppi.provider_personal_uploaded_docs
                        .where(image_classification: "release")
                        .order(created_at: :desc)

    # New preferred provider-level shared Release
    shared_release = release_scope.find_by(sub_section: nil)
    return shared_release if shared_release.present?

    # Backward compatibility for old section-specific uploads
    if @release_sub_section.present?
      section_release = release_scope.find_by(sub_section: @release_sub_section.to_s)
      return section_release if section_release.present?
    end

    nil
  end

  def convert_tiff_to_pdf_with_header_footer(tiff_path)
    raise StandardError, "TIFF not found: #{tiff_path}" unless File.exist?(tiff_path)

    pdf_pages = CombinePDF.new
    temp_dir = Dir.mktmpdir("tiff_frames_")

    begin
      output_pattern = File.join(temp_dir, "frame_%04d.png")

      MiniMagick::Tool.new("convert") do |convert|
        convert << tiff_path
        convert << "-coalesce"
        convert << output_pattern
      end

      frame_files = Dir.glob(File.join(temp_dir, "frame_*.png")).sort

      raise StandardError, "No TIFF frames could be extracted" if frame_files.empty?

      Rails.logger.info("🖼️ TIFF extracted into #{frame_files.count} page(s)")

      header_html = ApplicationController.render(template: @header_template, layout: false)
      footer_html = ApplicationController.render(template: @footer_template, layout: false)

      frame_files.each_with_index do |frame_path, index|
        Rails.logger.info("🖼️ Rendering TIFF page #{index + 1}/#{frame_files.count}")

        base64_png = Base64.strict_encode64(File.binread(frame_path))

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

              <div class="release-page">
                <div class="release-content">
                  <img src="data:image/png;base64,#{base64_png}" />
                </div>
              </div>

              <div class="footer">#{footer_html}</div>
            </body>
          </html>
        HTML

        page_pdf_binary = WickedPdf.new.pdf_from_string(
          html,
          margin: {
            top: 0,
            bottom: 0,
            left: 15,
            right: 15
          },
          page_size: "Letter",
          zoom: 1.0
        )

        pdf_pages << CombinePDF.parse(page_pdf_binary)
      end

      pdf_pages.to_pdf
    ensure
      FileUtils.remove_entry(temp_dir) if temp_dir && Dir.exist?(temp_dir)
    end
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
        padding-top: 70px;
        padding-bottom: 60px;
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

      .release-page {
        width: 100%;
        box-sizing: border-box;
        padding: 85px 20px 70px 20px;
      }

      .release-content {
        width: 100%;
        text-align: center;
      }

      .release-content img {
        display: block;
        width: 100%;
        height: auto;
        max-width: 100%;
        margin: 0 auto;
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