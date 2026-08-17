# frozen_string_literal: true

module Ssa
  class DeathMasterLookupService
    Result = Struct.new(
      :status,
      :records,
      :best_record,
      :matched_record_count,
      :ssn_matched,
      :first_name_matched,
      :middle_name_matched,
      :last_name_matched,
      :date_of_birth_matched,
      :details,
      keyword_init: true
    )

    def initialize(
      ssn:,
      first_name:,
      last_name:,
      middle_name: nil,
      date_of_birth: nil
    )
      @ssn = normalize_ssn(ssn)
      @first_name = normalize_name(first_name)
      @middle_name = normalize_name(middle_name)
      @last_name = normalize_name(last_name)
      @date_of_birth = normalize_date(date_of_birth)
    end

    def call
      validate_ssn!

      records = fetch_records

      return not_matched_result if records.empty?

      scored_records = records.map do |record|
        score_record(record)
      end

      best_result = scored_records.max_by do |result|
        result.fetch(:score)
      end

      Result.new(
        status: determine_status(best_result, scored_records),
        records: records,
        best_record: best_result.fetch(:record),
        matched_record_count: records.length,
        ssn_matched: true,
        first_name_matched: best_result[:first_name_matched],
        middle_name_matched: best_result[:middle_name_matched],
        last_name_matched: best_result[:last_name_matched],
        date_of_birth_matched: best_result[:date_of_birth_matched],
        details: {
          score: best_result[:score],
          unique_record_count: records.length,
          conflicting_records: conflicting_records?(scored_records)
        }
      )
    rescue StandardError => error
      Rails.logger.error(
        "[SSA Lookup] #{error.class}: #{error.message}"
      )

      Result.new(
        status: "error",
        records: [],
        best_record: nil,
        matched_record_count: 0,
        ssn_matched: false,
        details: {
          error: error.message
        }
      )
    end

    private

    def fetch_records
      version = DmfFileVersion.current

      unless version
        raise StandardError,
              "No active SSA Death Master file is available."
      end

      DmfRecord
        .where(
          dmf_file_version_id: version.id,
          ssn: @ssn
        )
        .map do |record|
          {
            SSN: record.ssn,
            FirstName: record.first_name,
            MiddleName: record.middle_name,
            LastName: record.last_name,
            BirthDate: record.birth_date,
            DeathDate: record.death_date,
            SourceDate: record.source_date
          }
        end
    end

    def validate_ssn!
      return if @ssn.match?(/\A\d{9}\z/)

      raise ArgumentError, "SSN must contain exactly 9 digits."
    end

    def score_record(record)
      first_name_result = compare_name(
        record[:FirstName],
        @first_name
      )

      middle_name_result = compare_name(
        record[:MiddleName],
        @middle_name
      )

      last_name_result = compare_name(
        record[:LastName],
        @last_name
      )

      birth_date_result = compare_date(
        record[:BirthDate],
        @date_of_birth
      )

      score =
        100 +
        comparison_score(first_name_result, 25) +
        comparison_score(middle_name_result, 5) +
        comparison_score(last_name_result, 30) +
        comparison_score(birth_date_result, 40)

      {
        record: record,
        score: score,
        first_name_matched: first_name_result[:matched],
        middle_name_matched: middle_name_result[:matched],
        last_name_matched: last_name_result[:matched],
        date_of_birth_matched: birth_date_result[:matched]
      }
    end

    def compare_name(record_value, provider_value)
      record_name = normalize_name(record_value)

      if record_name.blank? || provider_value.blank?
        return {
          available: false,
          matched: nil
        }
      end

      {
        available: true,
        matched: record_name == provider_value
      }
    end

    def compare_date(record_value, provider_value)
      record_date = normalize_record_date(record_value)

      if record_date.blank? || provider_value.blank?
        return {
          available: false,
          matched: nil
        }
      end

      {
        available: true,
        matched: record_date == provider_value
      }
    end

    def comparison_score(result, points)
      return 0 unless result[:available]

      result[:matched] ? points : -points
    end

    def determine_status(best_result, scored_records)
      return "review_required" if conflicting_records?(scored_records)

      required_results = [
        best_result[:first_name_matched],
        best_result[:last_name_matched],
        best_result[:date_of_birth_matched]
      ].compact

      return "review_required" if required_results.empty?
      return "matched" if required_results.all?(true)

      "review_required"
    end

    def conflicting_records?(scored_records)
      identities = scored_records.map do |result|
        record = result.fetch(:record)

        [
          normalize_name(record[:FirstName]),
          normalize_name(record[:MiddleName]),
          normalize_name(record[:LastName]),
          normalize_record_date(record[:BirthDate]),
          normalize_record_date(record[:DeathDate])
        ]
      end

      identities.uniq.length > 1
    end

    def not_matched_result
      Result.new(
        status: "not_matched",
        records: [],
        best_record: nil,
        matched_record_count: 0,
        ssn_matched: false,
        first_name_matched: nil,
        middle_name_matched: nil,
        last_name_matched: nil,
        date_of_birth_matched: nil,
        details: {
          unique_record_count: 0
        }
      )
    end

    def normalize_ssn(value)
      value.to_s.gsub(/\D/, "")
    end

    def normalize_name(value)
      value.to_s.strip.upcase.presence
    end

    def normalize_date(value)
      return nil if value.blank?

      value.respond_to?(:to_date) ? value.to_date : Date.parse(value.to_s)
    rescue Date::Error, ArgumentError, TypeError
      nil
    end

    def normalize_record_date(value)
      date = normalize_date(value)

      return nil if date == Date.new(1900, 1, 1)

      date
    end
  end
end