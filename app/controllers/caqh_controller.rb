class CaqhController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token, only: [:upload_pdf]

  def show
  end

  def upload
    Caqh::ImportService.call(params)
  end

  def upload_pdf
    saved = []
    errors = []

    files = extract_uploaded_files(params)

    if files.empty?
      render json: { error: "No PDF uploaded" }, status: :bad_request and return
    end

    files.each do |uploaded|
      begin
        reader = PDF::Reader.new(uploaded.tempfile)
        full_text = reader.pages.map(&:text).join("\n")

        parsed = CaqhPdfParser.parse(full_text)

        # Normalize CAQH Provider ID
        caqh_id = parsed['caqh_provider_id']&.gsub(/\D/, "")

        provider = find_or_build_provider(parsed, caqh_id)

        # Ensure CAQH Attest ID
        provider.caqh_provider_attest_id ||= caqh_id

        # Ensure provider_attest exists
        provider.provider_attest ||= ProviderAttest.find_or_create_by!(
          caqh_provider_attest_id: provider.caqh_provider_attest_id
        )

        # Store full raw JSON for debugging
        provider.extracted_data = (provider.extracted_data || {}).merge(parsed)

        # ------------------------------------------------------------------
        # FIXED: Name parsing block moved OUTSIDE the provider_attest block
        # ------------------------------------------------------------------
        if parsed['provider_name'] && parsed['first_name'].blank?
          name = parsed['provider_name'].gsub(/\s+/, ' ').strip

          if name.include?(',')
            last, rest = name.split(',', 2).map(&:strip)
            first = rest.split(/\s+/).first
            parsed['first_name'] = first
            parsed['last_name']  = last
          else
            parts = name.split
            parsed['first_name'] = parts[0] if parts.any?
            parsed['last_name']  = parts.last if parts.size > 1
          end
        end
        # ------------------------------------------------------------------

        assign_parsed_to_model(provider, parsed)

        provider.save!

        saved << {
          filename: uploaded.original_filename,
          provider_id: provider.id,
          caqh_id: provider.caqh_provider_attest_id
        }

      rescue => e
        Rails.logger.error("CAQH PDF ERROR: #{e.class}: #{e.message}\n#{e.backtrace.first(10).join("\n")}")
        errors << { file: uploaded.original_filename, error: e.message }
      end
    end

    status = errors.empty? ? 200 : 207
    render json: { saved: saved, errors: errors }, status: status
  end

  private

  def extract_uploaded_files(params)
    params.values.select { |v| v.is_a?(ActionDispatch::Http::UploadedFile) }
  end

  def find_or_build_provider(parsed, caqh_id)
    if caqh_id.present?
      ppi = ProviderPersonalInformation.find_by(caqh_provider_attest_id: caqh_id)
      return ppi if ppi
    end

    if parsed['individual_npi'].present?
      ppi = ProviderPersonalInformation.find_by(npi: parsed['individual_npi'])
      return ppi if ppi
    end

    if parsed['npi'].present?
      ppi = ProviderPersonalInformation.find_by(npi: parsed['npi'])
      return ppi if ppi
    end

    ProviderPersonalInformation.new
  end

  def assign_parsed_to_model(provider, parsed)
    allowed = provider.attribute_names

    parsed.each do |key, val|
      next if val.blank?

      if allowed.include?(key)
        provider[key] = val
      else
        case key
        when 'birth_date', 'date_of_birth', 'dob'
          provider['dob'] ||= val if allowed.include?('dob')
        when /email/
          email_field = allowed & %w[email primary_email contact_email personal_email]
          provider[email_field.first] = val if email_field.any?
        when /phone/
          phone_field = allowed & %w[phone home_phone contact_number cell_phone phone_number]
          provider[phone_field.first] = val if phone_field.any?
        end
      end
    end
  end
end
