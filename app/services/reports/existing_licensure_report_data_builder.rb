module Reports
  class ExistingLicensureReportDataBuilder
    def initialize(provider_info:, provider_licensure:, rva_info:)
      @provider_info = provider_info
      @provider_licensure = provider_licensure
      @rva_info = rva_info
    end

    def call
      {
        PracID: @provider_info&.caqh_provider_attest_id,

        Npi: provider_npi,

        "Source Date": format_date(@rva_info&.source_date),

        LastName: @provider_info&.last_name,
        FirstName: @provider_info&.first_name,

        PractitionerType: practitioner_type,

        LicenseNumber: @provider_licensure&.license_number,
        LicenseState: @provider_licensure&.state&.name,

        ExpirationDate: format_date(@provider_licensure&.license_expiration_date),

        LicenseStatus: @provider_licensure&.license_comment,

        AdverseAction: adverse_action
      }
    end


    private

    def provider_npi
      @provider_info.try(:nid) ||
      @provider_info.try(:npi) ||
      @provider_info.try(:npi_number)
    end

    def practitioner_type
      @provider_info.try(:practitioner_type) ||
      @provider_info.try(:provider_type)
    end

    def license_status
      @provider_licensure.try(:status) || "Active"
    end

    def adverse_action
      @rva_info&.adverse_action.present? ? "Y" : "N"
    end

    def format_date(value)
      value&.strftime("%-m/%-d/%Y")
    end
  end
end
