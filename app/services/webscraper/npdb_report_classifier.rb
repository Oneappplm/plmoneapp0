# frozen_string_literal: true

module Webscraper
  class NpdbReportClassifier
    TYPE_ALIASES = {
      "mmpr" => :mmpr,
      "medical_malpractice_payment_report" => :mmpr,
      "medical_malpractice" => :mmpr,

      "aar" => :aar,
      "adverse_action_report" => :aar,

      "state_licensure" => :state_licensure,
      "state_licensure_or_certification_action" => :state_licensure,
      "licensure" => :state_licensure,

      "professional_society" => :professional_society,
      "professional_society_action" => :professional_society,

      "dea_federal" => :dea_federal,
      "dea" => :dea_federal,
      "federal_licensure" => :dea_federal,

      "government_administrative" => :government_administrative,
      "government_administrative_action" => :government_administrative,

      "clinical_privileges" => :clinical_privileges,
      "clinical_privileges_action" => :clinical_privileges,

      "judgment_conviction" => :judgment_conviction,
      "judgment_or_conviction" => :judgment_conviction,
      "jocr" => :judgment_conviction,

      "health_plan" => :health_plan,
      "health_plan_action" => :health_plan,

      "peer_review" => :peer_review,
      "peer_review_organization" => :peer_review,

      "exclusion_debarment" => :exclusion_debarment,
      "exclusion_or_debarment" => :exclusion_debarment
    }.freeze

    AAR_CATEGORY_MAP = {
      "state_licensure" => :state_licensure,
      "professional_society" => :professional_society,
      "dea_federal" => :dea_federal,
      "government_administrative" => :government_administrative,
      "clinical_privileges" => :clinical_privileges,
      "health_plan" => :health_plan,
      "peer_review" => :peer_review,
      "exclusion_debarment" => :exclusion_debarment
    }.freeze

    class << self
      def classify(report_node)
        return :unknown unless report_node

        information = report_node.at_xpath(".//*[local-name()='informationReported']")

        return :mmpr if information&.at_xpath(".//*[local-name()='mmpr']")
        return :judgment_conviction if information&.at_xpath(".//*[local-name()='jocr']")

        aar = information&.at_xpath(".//*[local-name()='aar']")
        return classify_aar(report_node, aar) if aar

        explicit_type = first_text(
          report_node,
          ".//*[local-name()='reportType']",
          ".//*[local-name()='type']",
          ".//*[local-name()='category']"
        )

        normalize(explicit_type)
      end

      def normalize(value)
        key = value.to_s
                   .strip
                   .downcase
                   .gsub(/[^a-z0-9]+/, "_")
                   .gsub(/\A_+|_+\z/, "")

        TYPE_ALIASES.fetch(key, :unknown)
      end

      private

      def classify_aar(report_node, aar_node)
        category = first_text(
          aar_node,
          ".//*[local-name()='reportCategory']",
          ".//*[local-name()='actionCategory']",
          ".//*[local-name()='category']",
          ".//*[local-name()='entityType']"
        )

        normalized = normalize(category)
        return normalized unless normalized == :unknown

        text = [
          first_text(aar_node, ".//*[local-name()='action']"),
          first_text(aar_node, ".//*[local-name()='classification']/*[local-name()='description']"),
          first_text(aar_node, ".//*[local-name()='basis']/*[local-name()='description']"),
          first_text(report_node, ".//*[local-name()='contact']/*[local-name()='entityName']")
        ].compact.join(" ").downcase

        return :state_licensure if text.match?(/state board|licensure|license|certification/)
        return :professional_society if text.match?(/professional society/)
        return :dea_federal if text.match?(/dea|drug enforcement|federal licensure/)
        return :clinical_privileges if text.match?(/clinical privilege|hospital privilege/)
        return :health_plan if text.match?(/health plan/)
        return :peer_review if text.match?(/peer review/)
        return :government_administrative if text.match?(/government|administrative/)
        return :exclusion_debarment if text.match?(/exclusion|debarment/)

        :aar
      end

      def first_text(node, *xpaths)
        xpaths.each do |xpath|
          value = node.at_xpath(xpath)&.text&.strip
          return value if value && !value.empty?
        end

        nil
      end
    end
  end
end
