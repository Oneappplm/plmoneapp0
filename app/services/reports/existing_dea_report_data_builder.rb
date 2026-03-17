module Reports
  class ExistingDeaReportDataBuilder
    def initialize(provider_info:, provider_dea:, rva_info:, dea_webcrawler_log: nil)
      @provider_info = provider_info
      @provider_dea  = provider_dea
      @rva_info      = rva_info
      @dea_webcrawler_log = dea_webcrawler_log
    end

    def call
      crawler_payload = @dea_webcrawler_log&.report_payload || {}

      {
        PractID: @provider_info&.caqh_provider_attest_id.to_s,
        NPI: provider_npi.to_s,
        Lastname: @provider_info&.last_name.to_s,
        FirstName: @provider_info&.first_name.to_s,
        PractitionerType: practitioner_type.to_s,
        State: state_value(crawler_payload).to_s,
        DeaNumber: dea_number_value(crawler_payload).to_s,
        ExpirationDate: expiration_date_value(crawler_payload).to_s,
        VerificationStatus: verification_status_value(crawler_payload).to_s,
        DrugSchedule: drug_schedule_value(crawler_payload).to_s,
        SourceDate: source_date_value(crawler_payload).to_s
      }
    end

    private

    def provider_npi
      @provider_info.try(:nid).presence ||
        @provider_info.try(:npi).presence ||
        @provider_info.try(:npi_number).presence
    end

    def practitioner_type
      @provider_info.try(:practitioner_type).presence ||
        @provider_info.try(:provider_type).presence ||
        @provider_info.try(:provider_type_name).presence
    end

    def state_value(crawler_payload)
      crawler_payload["state_on_page"].presence ||
        @provider_dea&.state
    end

    def dea_number_value(crawler_payload)
      crawler_payload["dea_number_on_page"].presence ||
        @provider_dea&.dea_number
    end

    def expiration_date_value(crawler_payload)
      crawler_payload["expiration_date_on_page"].presence ||
        format_date(@provider_dea&.expiration_date)
    end

    def verification_status_value(crawler_payload)
      status =
        crawler_payload["status_value"].presence ||
        crawler_payload["status_text"].presence ||
        @rva_info&.verification_status

      # Normalize to Active if verified
      return "Active" if status.to_s.downcase.include?("verified")

      status
    end

    def drug_schedule_value(crawler_payload)
      crawler_payload["schedules_on_page"].presence ||
        formatted_schedules
    end

    def source_date_value(crawler_payload)
      crawler_payload["source_date_on_page"].presence ||
        format_date(@rva_info&.received_date) ||
        format_date(@rva_info&.requested_date)
    end

    def formatted_schedules
      value = @provider_dea&.schedules_held

      case value
      when Array
        value.reject(&:blank?).join(" ")
      else
        value.to_s
      end
    end

    def format_date(value)
      value&.strftime("%-m/%-d/%Y")
    end
  end
end
