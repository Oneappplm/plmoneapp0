# frozen_string_literal: true
require 'axlsx'

module AppTrackers
  module Exporters
    class ProviderExcelExporter
      HEADER = [
        "First Name", "Last Name", "Address", "CAQH Provider ID", "Cred Status", "NPI", "Provider Status",
        "File Due Date", "Batch Description", "App Reviewed?", "Attempt Contact Method",
        "Last Attempt Date", "Attempt Status", "Attempt Comments",
        "Docs Uploaded Count", "Uploaded Docs Names",
        "Doc Received - Application Received Date", "Doc Received - Release Received Date",
        "Doc Received - Disclosure Questions Date", "Doc Received - Face Sheet Date",
        "Doc Received - Employment Gap Date", "Doc Received - Practice Information Date",
        "Doc Received - NPDB Findings Date", "Doc Received - Training Date",
        "Doc Received - Education Date", "Doc Received - Professional Resource Network Date",
        "Doc Received - DEA Date", "Doc Received - PA Sponsor Request Date",
        "Doc Received - Collaborative Agreement Date",
        "Docs Received - Application", "Docs Received - Release",
        "Docs Received - Disclosure Questions Explanation", "Docs Received - Face Sheet",
        "Docs Received - Employment Gap", "Docs Received - Practice Information",
        "Docs Received - NPDB Findings", "Docs Received - Training",
        "Docs Received - Education", "Docs Received - Professional Resource Network",
        "Docs Received - DEA", "Docs Received - PA Sponsor Request Form",
        "Docs Received - Collaborative Agreement",
        "Docs Received Application Comments", "Docs Received Release Comments",
        "Docs Received Disclosure Questions Comments", "Docs Received Face Sheet Comments",
        "Docs Received Employment Gap Comments", "Docs Received Practice Information Comments",
        "Docs Received NPDB Findings Comments", "Docs Received Training Comments",
        "Docs Received Education Comments", "Docs Received Professional Resource Network Comments",
        "Docs Received DEA Comments", "Docs Received PA Sponsor Request Comments",
        "Docs Received Collaborative Agreement Comments"
      ].freeze

      def initialize(providers)
        @providers = providers
      end

      def generate
        package = Axlsx::Package.new
        workbook = package.workbook

        workbook.add_worksheet(name: "Provider Summary") do |sheet|
          sheet.add_row HEADER

          @providers.each { |prov| sheet.add_row build_row(prov) }
        end

        package
      end

      private

      def build_row(prov)
        attest = prov.provider_attest
        practice = attest&.practice_informations&.first
        attempt = prov.provider_personal_attempts.last
        docs_uploaded = prov.provider_personal_docs_uploaded_documents
        docs_receive = prov.provider_personal_docs_receive

        [
          prov.first_name,
          prov.last_name,
          practice&.address,
          prov.caqh_provider_attest_id,
          prov.cred_status,
          practice&.npi,
          practice&.provider_status,
          practice&.file_due_date,
          practice&.batch_description,
          practice&.app_reviewed ? "Yes" : "No",
          attempt&.contact_method,
          format_date(attempt&.contact_date),
          attempt&.attempt_status,
          attempt&.comments,
          docs_uploaded.size,
          docs_uploaded.map { |d| File.basename(d.file_upload.to_s) }.join(", "),
          *docs_received_dates(docs_receive),
          *docs_received_flags(docs_receive),
          *docs_received_comments(docs_receive)
        ]
      end

      def format_date(date)
        date&.strftime("%m/%d/%Y")
      end

      def docs_received_dates(d)
        return Array.new(13) unless d
        [
          format_date(d.application_received_date),
          format_date(d.release_received_date),
          format_date(d.disclosure_questions_explanation_received_date),
          format_date(d.face_sheet_received_date),
          format_date(d.employment_gap_received_date),
          format_date(d.practice_information_received_date),
          format_date(d.npdb_findings_explanation_received_date),
          format_date(d.training_received_date),
          format_date(d.education_received_date),
          format_date(d.professional_resource_network_received_date),
          format_date(d.dea_received_date),
          format_date(d.pa_sponsor_request_form_received_date),
          format_date(d.collaborative_agreement_received_date)
        ]
      end

      def docs_received_flags(d)
        return Array.new(13) { "No" } unless d
        [
          d.application_received_flag,
          d.release_received_flag,
          d.disclosure_questions_explanation_received_flag,
          d.face_sheet_received_flag,
          d.employment_gap_received_flag,
          d.practice_information_received_flag,
          d.npdb_findings_explanation_received_flag,
          d.training_received_flag,
          d.education_received_flag,
          d.professional_resource_network_received_flag,
          d.dea_received_flag,
          d.pa_sponsor_request_form_received_flag,
          d.collaborative_agreement_received_flag
        ].map { |flag| flag ? "Yes" : "No" }
      end

      def docs_received_comments(d)
        return Array.new(13) unless d
        [
          d.application_comments,
          d.release_comments,
          d.disclosure_questions_explanation_comments,
          d.face_sheet_comments,
          d.employment_gap_comments,
          d.practice_information_comments,
          d.npdb_findings_explanation_comments,
          d.training_comments,
          d.education_comments,
          d.professional_resource_network_comments,
          d.dea_comments,
          d.pa_sponsor_request_form_comments,
          d.collaborative_agreement_comments
        ]
      end
    end
  end
end
