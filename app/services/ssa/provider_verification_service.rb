# frozen_string_literal: true

module Ssa
  class ProviderVerificationService
    class VerificationError < StandardError; end

    def initialize(provider:, verified_by: nil)
      @provider = provider
      @verified_by = verified_by
    end

    def call
      validate_provider!

      lookup_result = lookup_service.call

      if lookup_result.status == "error"
        raise VerificationError,
              lookup_result.details&.dig(:error) ||
              "SSA Death Master lookup failed."
      end

      verification = save_verification(lookup_result)

      generate_pdf!(verification)

      verification.reload
    rescue StandardError => error
      Rails.logger.error(
        "[SSA Provider Verification] " \
        "provider_id=#{@provider&.id} " \
        "error=#{error.class}: #{error.message}"
      )

      save_or_update_error_verification(error)
    end

    private

    def lookup_service
      Ssa::DeathMasterLookupService.new(
        ssn: @provider.ssn,
        first_name: @provider.first_name,
        middle_name: provider_middle_name,
        last_name: @provider.last_name,
        date_of_birth: provider_date_of_birth
      )
    end

    def validate_provider!
      unless normalized_ssn.match?(/\A\d{9}\z/)
        raise VerificationError,
              "Provider SSN must contain exactly 9 digits."
      end

      if @provider.first_name.blank? || @provider.last_name.blank?
        raise VerificationError,
              "Provider first name and last name are required."
      end
    end

    def save_verification(result)
      record = result.best_record

      @verification =
        @provider.provider_ssn_verifications.create!(
          provider_attest_id: provider_attest_id,
          verified_by: @verified_by,
          status: result.status,
          ssn_last_four: normalized_ssn.last(4),
          ssn_matched: result.ssn_matched,
          first_name_matched: result.first_name_matched,
          middle_name_matched: result.middle_name_matched,
          last_name_matched: result.last_name_matched,
          date_of_birth_matched: result.date_of_birth_matched,
          matched_record_count: result.matched_record_count,
          death_date: normalize_date(record&.dig(:DeathDate)),
          source_date: normalize_datetime(
            record&.dig(:SourceDate)
          ),
          verification_details: {
            provider: provider_details,
            death_master: normalize_death_master_record(record),
            match: result.details
          },
          verified_at: Time.current
        )
    end

    def generate_pdf!(verification)
      Ssa::VerificationPdfGenerator.new(verification).call

      unless verification.report_pdf.attached?
        raise VerificationError,
              "SSA verification completed, but the PDF was not generated."
      end
    end

    def save_or_update_error_verification(error)
      if @verification&.persisted?
        @verification.update!(
          status: "error",
          error_message: error.message
        )

        return @verification
      end

      @provider.provider_ssn_verifications.create!(
        provider_attest_id: provider_attest_id,
        verified_by: @verified_by,
        status: "error",
        ssn_last_four: normalized_ssn.last(4),
        ssn_matched: false,
        matched_record_count: 0,
        verification_details: {},
        verified_at: Time.current,
        error_message: error.message
      )
    end

    def provider_details
      {
        first_name: clean_text(@provider.first_name),
        middle_name: clean_text(provider_middle_name),
        last_name: clean_text(@provider.last_name),
        date_of_birth: normalize_date(provider_date_of_birth)
      }
    end

    def normalize_death_master_record(record)
      return {} if record.blank?

      {
        ssn_last_four: record[:SSN].to_s.gsub(/\D/, "").last(4),
        first_name: clean_text(record[:FirstName]),
        middle_name: clean_text(record[:MiddleName]),
        last_name: clean_text(record[:LastName]),
        birth_date: normalize_date(record[:BirthDate]),
        death_date: normalize_date(record[:DeathDate]),
        source_date: normalize_datetime(record[:SourceDate])
      }
    end

    def normalized_ssn
      @normalized_ssn ||= @provider.ssn.to_s.gsub(/\D/, "")
    end

    def provider_attest_id
      return unless @provider.respond_to?(:provider_attest_id)

      @provider.provider_attest_id
    end

    def provider_middle_name
      return @provider.middle_name if @provider.respond_to?(:middle_name)
      return @provider.middle_initial if @provider.respond_to?(:middle_initial)

      nil
    end

    def provider_date_of_birth
      return @provider.date_of_birth if @provider.respond_to?(:date_of_birth)
      return @provider.dob if @provider.respond_to?(:dob)
      return @provider.birth_date if @provider.respond_to?(:birth_date)

      nil
    end

    def clean_text(value)
      value.to_s.strip.presence
    end

    def normalize_date(value)
      return nil if value.blank?

      if value.respond_to?(:to_date)
        value.to_date
      else
        Date.parse(value.to_s)
      end
    rescue Date::Error, ArgumentError, TypeError
      nil
    end

    def normalize_datetime(value)
      return nil if value.blank?

      if value.respond_to?(:in_time_zone)
        value.in_time_zone
      else
        Time.zone.parse(value.to_s)
      end
    rescue ArgumentError, TypeError
      nil
    end
  end
end