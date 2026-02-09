# app/services/ai_search/query_router.rb

module AiSearch
  class QueryRouter
    def initialize(intent)
      @intent = intent
    end

    def call
      case @intent[:entity]
      when :users
        users_query
      when :licenses
        license_query
      when :dea
        dea_query
      when :board_certification
        board_query
      else
        provider_query
      end
    end

    private

    def users_query
      {
        records: User.all,
        columns: %i[id first_name last_name email user_role],
        title: "All Users"
      }
    end

    def license_query
      records = ProviderLicensure
                  .joins(provider_attest: :provider_personal_informations)
                  .includes(provider_attest: :provider_personal_informations)

      case @intent[:filter]
      when :expired
        records = records.where("provider_licensures.license_expiration_date < ?", Date.current)
      when :active
        records = records.where("provider_licensures.license_expiration_date >= ?", Date.current)
      end

      if @intent[:year].present?
        records = records.where(
          "EXTRACT(YEAR FROM provider_licensures.license_expiration_date) = ?",
          @intent[:year]
        )
      end

      {
        records: records,
        columns: %i[provider_name license_number license_expiration_date license_type],
        title: @intent[:filter] == :expired ? "Expired State Licenses" : "State Licenses",
        license_type: "State License"
      }
    end


    def dea_query
      records = ProviderDea
                  .joins(provider_attest: :provider_personal_informations)
                  .includes(provider_attest: :provider_personal_informations)

      if @intent[:filter] == :expired
        records = records.where("provider_deas.expiration_date < ?", Date.current)
      end

      if @intent[:year].present?
        records = records.where(
          "EXTRACT(YEAR FROM provider_deas.expiration_date) = ?",
          @intent[:year]
        )
      end

      {
        records: records,
        columns: %i[provider_name dea_number expiration_date license_type],
        title: "DEA Licenses",
        license_type: "DEA License"
      }
    end

    def board_query
      records = ProviderSpecialty
                  .joins(provider_attest: :provider_personal_informations)
                  .includes(provider_attest: :provider_personal_informations)

      if @intent[:filter] == :expired
        records = records.where("provider_specialties.expiration_date < ?", Date.today)
      end

      if @intent[:year].present?
        records = records.where(
          "EXTRACT(YEAR FROM provider_specialties.expiration_date) = ?",
          @intent[:year]
        )
      end

      {
        records: records,
        columns: %i[first_name last_name expiration_date specialty_board_name],
        title: "Board Certifications",
        license_type: "Board Certification"
      }
    end

    def provider_query
      {
        records: ProviderPersonalInformation.includes(:provider_attest),
        columns: %i[first_name last_name caqh_provider_attest_id],
        title: "All Providers"
      }
    end
  end
end
