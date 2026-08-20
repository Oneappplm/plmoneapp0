# frozen_string_literal: true

module Webscraper
  class NpdbCodeLookup
    CODES = {
      sex: {
        "M" => "Male",
        "F" => "Female",
        "U" => "Unknown"
      },
      occupation: {
        "010" => "Physician (MD)",
        "015" => "Physician (MD) Resident",
        "020" => "Physician (DO)",
        "025" => "Physician (DO) Resident",
        "030" => "Dentist (DDS/DMD)",
        "100" => "Registered Nurse",
        "130" => "Nurse Practitioner",
        "642" => "Physician Assistant"
      },
      report_transaction: {
        "I" => "Initial",
        "C" => "Correction",
        "V" => "Void"
      },
      statutory_authority: {
        "IV" => "Title IV",
        "1921" => "Section 1921",
        "1128E" => "Section 1128E"
      },
      dispute_status: {
        "N" => "Not disputed",
        "D" => "Disputed",
        "R" => "Under review",
        "S" => "Subject statement on file"
      },
      mmpr_relationship: {
        "P" => "INSURANCE COMPANY - PRIMARY INSURER",
        "E" => "INSURANCE COMPANY - EXCESS INSURER",
        "S" => "SELF-INSURED ORGANIZATION",
        "G" => "INSURANCE GUARANTY FUND",
        "M" => "STATE MEDICAL MALPRACTICE PAYMENT FUND - PRIMARY PAYER",
        "O" => "STATE MEDICAL MALPRACTICE PAYMENT FUND - SECONDARY PAYER"
      },
      mmpr_payment_type: {
        "S" => "A SINGLE FINAL PAYMENT",
        "M" => "ONE OF MULTIPLE PAYMENTS",
        "U" => "UNKNOWN PAYMENT TYPE"
      },
      mmpr_payment_result: {
        "S" => "Settlement",
        "J" => "Judgment",
        "O" => "Other"
      },
      mmpr_patient_type: {
        "I" => "Inpatient",
        "O" => "Outpatient",
        "E" => "Emergency Department",
        "U" => "Unknown"
      },
      mmpr_nature: {
        "060" => "Treatment Related"
      },
      mmpr_specific_allegation: {
        "305" => "Improper Management"
      },
      mmpr_outcome: {
        "09" => "Death"
      },
      aar_action: {},
      aar_classification: {},
      aar_basis: {}
    }.freeze

    class << self
      CODES.each_key do |group|
        define_method(group) do |code|
          fetch(group, code)
        end
      end

      def fetch(group, code)
        normalized = normalize(code)
        return "" if normalized.empty?

        external_codes.dig(group.to_sym, normalized) ||
          CODES.dig(group.to_sym, normalized) ||
          normalized
      end

      def display(code, label)
        normalized_code = normalize(code)
        normalized_label = label.to_s.strip

        return normalized_label if normalized_code.empty?
        return normalized_code if normalized_label.empty?
        return normalized_label if normalized_label == normalized_code
        return normalized_label if normalized_label.include?("(#{normalized_code})")

        "#{normalized_label} (#{normalized_code})"
      end

      private

      def normalize(code)
        code.to_s.strip.upcase
      end

      # Optional project override. Create config/npdb_code_lookup.yml with:
      # production:
      #   mmpr_nature:
      #     "060": "Treatment Related"
      def external_codes
        return {} unless defined?(Rails)

        @external_codes ||= begin
          path = Rails.root.join("config", "npdb_code_lookup.yml")
          unless File.exist?(path)
            {}
          else
            raw = YAML.safe_load(File.read(path), aliases: true) || {}
            environment_codes = raw.fetch(Rails.env, raw)

            environment_codes.each_with_object({}) do |(group, values), result|
              result[group.to_sym] = values.to_h.transform_keys { |key| normalize(key) }
            end
          end
        rescue StandardError => e
          Rails.logger.warn("NPDB code lookup YAML could not be loaded: #{e.message}")
          {}
        end
      end
    end
  end
end
