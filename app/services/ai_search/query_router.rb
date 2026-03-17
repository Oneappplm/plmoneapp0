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

    def dea_title
      case @intent[:filter]
      when :expired
        "Expired DEA Licenses"
      when :expiring_soon
        "DEA Licenses Expiring Soon"
      else
        "DEA Licenses"
      end
    end

    def state_license_title
      case @intent[:filter]
      when :expired
        "Expired State Licenses"
      when :expiring_soon
        "State Licenses Expiring Soon"
      when :active
        "Active State Licenses"
      else
        "State Licenses"
      end
    end

    private

    def resolve_state_id
      return nil if @intent[:state].blank?

      # Normalize "fl" / "FL" / "Florida" → "FL"
      alpha_code = AiSearch::StateNormalizer.normalize(@intent[:state])

      return nil if alpha_code.blank?

      State.find_by(alpha_code: alpha_code)&.id
    end

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

      today = Date.current

      case @intent[:filter]
      when :expired
        records = records.where(
          "provider_licensures.license_expiration_date < ?", today
        )

      when :active
        records = records.where(
          "provider_licensures.license_expiration_date >= ?", today
        )

      when :expiring_soon
        records = records.where(
          provider_licensures: {
            license_expiration_date: today..(today + 5.years)
          }
        )
      end

      if @intent[:year].present?
        records = records.where(
          "EXTRACT(YEAR FROM provider_licensures.license_expiration_date) = ?",
          @intent[:year]
        )
      end

      state_id = resolve_state_id
      records = records.where(provider_licensures: { state_id: state_id }) if state_id

      {
        records: records,
        columns: %i[
          provider_name
          license_number
          license_type
          license_expiration_date
          state
        ],
        title: state_license_title,
        license_type: "State License"
      }
    end




    def dea_query
      records = ProviderDea
                  .joins(provider_attest: :provider_personal_informations)
                  .includes(provider_attest: :provider_personal_informations)

      today = Date.current

      case @intent[:filter]
      when :expired
        records = records.where("provider_deas.expiration_date < ?", today)

      when :expiring_soon
        records = records.where(
          provider_deas: {
            expiration_date: today..(today + 5.years)
          }
        )
      end

      if @intent[:year].present?
        records = records.where(
          "EXTRACT(YEAR FROM provider_deas.expiration_date) = ?",
          @intent[:year]
        )
      end

      if @intent[:state].present?
        records = records.where(
          "provider_deas.state = ? OR provider_personal_informations.state = ?",
          @intent[:state],
          @intent[:state]
        )
      end

      {
        records: records,
        columns: %i[provider_name dea_number expiration_date license_type state],
        title: dea_title,
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
