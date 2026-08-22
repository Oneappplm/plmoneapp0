# app/services/dmf/import_service.rb
# frozen_string_literal: true

require "digest"
require "zlib"
require "tempfile"

module Dmf
  class ImportService
    class ImportError < StandardError; end

    EXPECTED_FULL_ROW_COUNT = 91_682_810

    def initialize(version)
      @version = version
    end

    def call
      @version.update!(
        status: "importing",
        import_started_at: Time.current,
        error_message: nil
      )

      Tempfile.create(
        ["dmf_#{@version.id}", ".tsv.gz"],
        binmode: true
      ) do |file|
        artifact_store.download(
          @version.artifact_key,
          file.path
        )

        verify_checksum!(file.path)

        import_into_staging!(file.path)
      end

      validate_staging!
      activate_import!

      @version.reload
    rescue StandardError => error
      @version.update!(
        status: "failed",
        error_message: error.message
      )

      Rails.logger.error(
        "[DMF Import #{@version.id}] " \
        "#{error.class}: #{error.message}"
      )

      raise
    end

    private

    def artifact_store
      @artifact_store ||= Dmf::ArtifactStore.new
    end

    def verify_checksum!(path)
      actual =
        Digest::SHA256.file(path).hexdigest

      return if ActiveSupport::SecurityUtils.secure_compare(
        actual,
        @version.sha256
      )

      raise ImportError,
            "DMF artifact checksum does not match."
    end

    def import_into_staging!(path)
      create_staging_table!

      raw_connection =
        ActiveRecord::Base.connection.raw_connection

      copy_sql = <<~SQL
        COPY dmf_records_staging (
          ssn,
          last_name,
          first_name,
          middle_name,
          birth_date,
          death_date,
          source_date
        )
        FROM STDIN
        WITH (
          FORMAT csv,
          DELIMITER E'\\t',
          HEADER true,
          NULL '\\N',
          QUOTE E'\\b'
        )
      SQL

      Zlib::GzipReader.open(path) do |gzip|
        raw_connection.copy_data(copy_sql) do
          while (chunk = gzip.read(1024 * 1024))
            raw_connection.put_copy_data(chunk)
          end
        end
      end
    end

    def create_staging_table!
      connection.execute(
        "DROP TABLE IF EXISTS dmf_records_staging"
      )

      connection.execute(<<~SQL)
        CREATE UNLOGGED TABLE dmf_records_staging (
          ssn varchar(9) NOT NULL,
          last_name varchar,
          first_name varchar,
          middle_name varchar,
          birth_date date,
          death_date date,
          source_date timestamp
        );
      SQL
    end

    def validate_staging!
      @version.update!(status: "validating")

      count =
        connection.select_value(
          "SELECT COUNT(*) FROM dmf_records_staging"
        ).to_i

      raise ImportError, "DMF import produced zero rows." if count.zero?

      if count != EXPECTED_FULL_ROW_COUNT
        raise ImportError,
              "DMF row count mismatch. " \
              "Expected #{EXPECTED_FULL_ROW_COUNT}, got #{count}."
      end

      invalid_ssns =
        connection.select_value(<<~SQL).to_i
          SELECT COUNT(*)
          FROM dmf_records_staging
          WHERE ssn !~ '^[0-9]{9}$';
        SQL

      if invalid_ssns.positive?
        raise ImportError,
              "DMF import contains #{invalid_ssns} invalid SSNs."
      end

      @imported_row_count = count
    end

    def activate_import!
      version_id =
        connection.quote(@version.id)

      connection.transaction do
        connection.execute(
          "TRUNCATE TABLE dmf_records"
        )

        connection.execute(<<~SQL)
          INSERT INTO dmf_records (
            ssn,
            last_name,
            first_name,
            middle_name,
            birth_date,
            death_date,
            source_date,
            dmf_file_version_id
          )
          SELECT
            ssn,
            last_name,
            first_name,
            middle_name,
            birth_date,
            death_date,
            source_date,
            #{version_id}
          FROM dmf_records_staging;
        SQL

        connection.execute(
          "DROP TABLE dmf_records_staging"
        )

        DmfFileVersion.where(active: true)
                      .where.not(id: @version.id)
                      .update_all(active: false)

        @version.update!(
          active: true,
          status: "completed",
          row_count: @imported_row_count,
          import_completed_at: Time.current
        )
      end

      connection.execute(
        "ANALYZE dmf_records"
      )
    end

    def connection
      ActiveRecord::Base.connection
    end
  end
end