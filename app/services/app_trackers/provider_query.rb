# frozen_string_literal: true
module AppTrackers
  class ProviderQuery
    def initialize(params)
      @params = params
    end

    def call
      scope = ProviderPersonalInformation
                .includes(
                  :provider_personal_attempts,
                  :provider_personal_docs_uploaded_documents,
                  :provider_personal_docs_receive,
                  provider_attest: :practice_informations
                )
                .where.not(cred_status: 'no-application')

      if @params[:user_search].present?
        search_term = "%#{@params[:user_search]}%"
        scope = scope.left_joins(provider_source: :data)
                     .where(
                       <<~SQL.squish, term: search_term
                         provider_personal_informations.first_name ILIKE :term OR
                         provider_personal_informations.middle_name ILIKE :term OR
                         provider_personal_informations.last_name ILIKE :term OR
                         CAST(provider_personal_informations.caqh_provider_attest_id AS TEXT) ILIKE :term OR
                         (provider_source_data.data_key IN ('first_name', 'middle_name', 'last_name')
                           AND provider_source_data.data_value ILIKE :term)
                       SQL
                     ).distinct
      end

      scope
    end
  end
end
