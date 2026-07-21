# frozen_string_literal: true

require "date"

class DeaMasterImporter
  BATCH_SIZE = 2_000
  BYTES_PROGRESS_EVERY = 2 * 1024 * 1024

  # Fixed-width DEA master layout:
  #
  # Master DEA Value       0..9
  #   - Characters 0..8 = standard DEA number
  #   - Character 9       = business activity code
  #
  # Reserved              10..12
  # Schedules             13..23
  # Expiration Date       26..33
  # Provider Name         34..73
  # Organization Name     74..113
  # Address 1            114..149
  # Address 2            150..193
  # City                 194..226
  # State                227..228
  # ZIP                  229..234
  # Status               236..242
  # Degree               245..246
  # State License        255..294

  FIELD_MAP = {
    master_dea_value: 0..9,
    schedules: 13..23,
    expiration_raw: 26..33,
    name: 34..73,
    organization_name: 74..113,
    address1: 114..149,
    address2: 150..193,
    city: 194..226,
    state: 227..228,
    zip: 229..234,
    status: 236..242,
    degree: 245..246,
    state_license_number: 255..294
  }.freeze

  def initialize(file_path, job_id)
    @file_path = file_path
    @job_id = job_id
  end

  def import!
    import_chunk!
  end

  def import_chunk!
    redis = $redis
    redis_key = "dea_import:#{@job_id}"

    validate_file!

    total_bytes = File.size(@file_path).to_i

    initialize_progress!(
      redis: redis,
      redis_key: redis_key,
      total_bytes: total_bytes
    )

    processed = 0
    imported = 0
    skipped = 0
    bytes_read = 0
    next_progress_at = BYTES_PROGRESS_EVERY

    buffer = []
    current_time = Time.current

    File.open(@file_path, "rb") do |io|
      io.each_line do |raw_line|
        processed += 1
        bytes_read += raw_line.bytesize

        line = sanitize(raw_line)
               .delete_suffix("\n")
               .delete_suffix("\r")

        if line.strip.blank?
          skipped += 1
          next
        end

        attributes = extract_attributes(line)

        unless valid_dea_number?(attributes[:dea_number])
          skipped += 1

          Rails.logger.warn(
            "[DEA IMPORT] Skipping line=#{processed} " \
            "invalid_dea=#{attributes[:dea_number].inspect}"
          )

          next
        end

        attributes[:created_at] = current_time
        attributes[:updated_at] = current_time

        buffer << attributes
        imported += 1

        if buffer.size >= BATCH_SIZE
          flush!(buffer)
          buffer.clear
        end

        next unless bytes_read >= next_progress_at

        update_progress(
          redis: redis,
          redis_key: redis_key,
          processed: processed,
          imported: imported,
          skipped: skipped,
          bytes_read: bytes_read,
          total_bytes: total_bytes
        )

        next_progress_at = bytes_read + BYTES_PROGRESS_EVERY
      end
    end

    flush!(buffer) if buffer.any?

    # Synchronize existing ProviderDea rows after the complete file
    # has been successfully imported.
    sync_result = sync_provider_deas

    finish_progress!(
      redis: redis,
      redis_key: redis_key,
      processed: processed,
      imported: imported,
      skipped: skipped,
      total_bytes: total_bytes,
      sync_result: sync_result
    )

    Rails.logger.info(
      "[DEA IMPORT] Completed " \
      "processed=#{processed} " \
      "imported=#{imported} " \
      "skipped=#{skipped} " \
      "provider_deas_updated=#{sync_result[:updated]} " \
      "provider_deas_manual=#{sync_result[:manual]}"
    )

    {
      processed: processed,
      imported: imported,
      skipped: skipped,
      provider_deas_updated: sync_result[:updated],
      provider_deas_manual: sync_result[:manual]
    }
  rescue StandardError => e
    Rails.logger.error(
      "[DEA IMPORT] Failed #{e.class}: #{e.message}"
    )

    Rails.logger.error(
      Array(e.backtrace).first(30).join("\n")
    )

    mark_failed!(
      redis: redis,
      redis_key: redis_key,
      error: e
    ) if defined?(redis) && redis.present? &&
         defined?(redis_key) && redis_key.present?

    raise
  end

  private

  def validate_file!
    if @file_path.blank?
      raise ArgumentError, "DEA import file path is missing."
    end

    unless File.exist?(@file_path)
      raise ArgumentError,
            "DEA import file does not exist: #{@file_path}"
    end

    if File.zero?(@file_path)
      raise ArgumentError, "DEA import file is empty."
    end
  end

  def initialize_progress!(redis:, redis_key:, total_bytes:)
    redis.pipelined do |pipeline|
      pipeline.hset(redis_key, "total_bytes", total_bytes)
      pipeline.hset(redis_key, "bytes_read", 0)
      pipeline.hset(redis_key, "status", "running")
      pipeline.hset(redis_key, "processed", 0)
      pipeline.hset(redis_key, "imported", 0)
      pipeline.hset(redis_key, "skipped", 0)
      pipeline.hset(redis_key, "provider_deas_updated", 0)
      pipeline.hset(redis_key, "provider_deas_manual", 0)
      pipeline.hset(redis_key, "error", "")
      pipeline.hset(redis_key, "last_update", Time.current.to_i)
    end
  end

  def finish_progress!(
    redis:,
    redis_key:,
    processed:,
    imported:,
    skipped:,
    total_bytes:,
    sync_result:
  )
    redis.pipelined do |pipeline|
      pipeline.hset(redis_key, "processed", processed)
      pipeline.hset(redis_key, "imported", imported)
      pipeline.hset(redis_key, "skipped", skipped)
      pipeline.hset(redis_key, "bytes_read", total_bytes)
      pipeline.hset(redis_key, "total_bytes", total_bytes)
      pipeline.hset(redis_key, "total", processed)

      pipeline.hset(
        redis_key,
        "provider_deas_updated",
        sync_result[:updated]
      )

      pipeline.hset(
        redis_key,
        "provider_deas_manual",
        sync_result[:manual]
      )

      pipeline.hset(redis_key, "status", "finished")
      pipeline.hset(redis_key, "last_update", Time.current.to_i)
    end
  end

  def mark_failed!(redis:, redis_key:, error:)
    redis.pipelined do |pipeline|
      pipeline.hset(redis_key, "status", "failed")
      pipeline.hset(
        redis_key,
        "error",
        "#{error.class}: #{error.message}"
      )
      pipeline.hset(redis_key, "last_update", Time.current.to_i)
    end
  end

  def flush!(rows)
    return if rows.blank?

    DeaMasterRecord.upsert_all(
      rows,
      unique_by: :index_dea_master_records_on_dea_number
    )
  rescue StandardError => e
    Rails.logger.error(
      "[DEA IMPORT] Bulk upsert failed " \
      "rows=#{rows.size} " \
      "error=#{e.class}: #{e.message}"
    )

    raise
  end

  def extract_attributes(line)
    raw_values = {}

    FIELD_MAP.each do |field, range|
      raw_values[field] =
        sanitize(safe_slice(line, range)).strip
    end

    master_dea_value =
      normalize_master_dea_value(
        raw_values[:master_dea_value]
      )

    standard_dea_number =
      master_dea_value.first(9)

    business_activity_code =
      master_dea_value[9]

    {
      dea_number: standard_dea_number,
      schedules: normalize_schedules(
        raw_values[:schedules]
      ),
      expiration_date: parse_date(
        raw_values[:expiration_raw]
      ),
      name: combined_name(
        raw_values[:name],
        raw_values[:organization_name]
      ),
      business_activity:
        normalized_text(business_activity_code),
      address1: normalized_text(
        raw_values[:address1]
      ),
      address2: normalized_text(
        raw_values[:address2]
      ),
      city: normalized_text(
        raw_values[:city]
      ),
      state: normalize_state(
        raw_values[:state]
      ),
      zip: normalize_zip(
        raw_values[:zip]
      ),
      status: normalized_text(
        raw_values[:status]
      ),
      degree: normalized_text(
        raw_values[:degree]
      ),
      state_license_number:
        normalized_text(
          raw_values[:state_license_number]
        )
    }
  end

  def combined_name(provider_name, organization_name)
    values = [
      normalized_text(provider_name),
      normalized_text(organization_name)
    ].compact

    values.join(" ").squish.presence
  end

  def safe_slice(line, range)
    return "" if line.blank? || range.blank?
    return "" if line.length <= range.begin

    line[range] || ""
  end

  def sanitize(value)
    value.to_s.encode(
      "UTF-8",
      invalid: :replace,
      undef: :replace,
      replace: "?"
    )
  end

  # The imported master field contains:
  #
  # MG6295643M
  #
  # MG6295643 = standard DEA number
  # M         = business activity code
  def normalize_master_dea_value(value)
    value.to_s
         .upcase
         .gsub(/[^A-Z0-9]/, "")
         .first(10)
  end

  def normalize_dea_number(value)
    value.to_s
         .upcase
         .gsub(/[^A-Z0-9]/, "")
         .first(9)
  end

  def valid_dea_number?(value)
    normalize_dea_number(value)
      .match?(/\A[A-Z]{2}\d{7}\z/)
  end

  def normalize_schedules(value)
    raw = value.to_s.upcase.squish

    schedules = []

    if raw.include?("22N") ||
       raw.match?(/(?:^|\s)2(?:\s|$)/)
      schedules << "2"
    end

    schedules << "2N" if raw.include?("2N")

    if raw.include?("33N") ||
       raw.match?(/(?:^|\s)3(?:\s|$)/)
      schedules << "3"
    end

    schedules << "3N" if raw.include?("3N")

    if raw.match?(/(?:^|\s)4(?:\s|$)/)
      schedules << "4"
    end

    if raw.match?(/(?:^|\s)5(?:\s|$)/)
      schedules << "5"
    end

    schedules.uniq.join(",")
  end

  def normalize_state(value)
    state = value.to_s
                 .upcase
                 .gsub(/[^A-Z]/, "")

    state.match?(/\A[A-Z]{2}\z/) ? state : nil
  end

  def normalize_zip(value)
    digits = value.to_s.gsub(/\D/, "")

    digits.present? ? digits.first(5) : nil
  end

  def normalized_text(value)
    value.to_s.squish.presence
  end

  def parse_date(raw)
    value = raw.to_s.gsub(/\D/, "")

    return nil unless value.match?(/\A\d{8}\z/)
    return nil if %w[00000000 99999999].include?(value)
    return nil if value.start_with?("0000")

    Date.strptime(value, "%Y%m%d")
  rescue Date::Error, ArgumentError
    nil
  end

  def update_progress(
    redis:,
    redis_key:,
    processed:,
    imported:,
    skipped:,
    bytes_read:,
    total_bytes:
  )
    average_bytes =
      processed.positive? ? bytes_read.to_f / processed : 0

    estimated_total =
      if average_bytes.positive?
        (total_bytes / average_bytes).to_i
      else
        processed
      end

    redis.pipelined do |pipeline|
      pipeline.hset(redis_key, "processed", processed)
      pipeline.hset(redis_key, "imported", imported)
      pipeline.hset(redis_key, "skipped", skipped)
      pipeline.hset(redis_key, "bytes_read", bytes_read)

      pipeline.hset(
        redis_key,
        "total",
        estimated_total.positive? ?
          estimated_total :
          processed
      )

      pipeline.hset(redis_key, "status", "running")
      pipeline.hset(redis_key, "last_update", Time.current.to_i)
    end
  end

  def sync_provider_deas
    return default_sync_result unless defined?(
      DeaMasterProviderSyncService
    )

    DeaMasterProviderSyncService.new.call
  rescue StandardError => e
    Rails.logger.error(
      "[DEA IMPORT] ProviderDea sync failed " \
      "#{e.class}: #{e.message}"
    )

    default_sync_result.merge(error: e.message)
  end

  def default_sync_result
    {
      updated: 0,
      manual: 0,
      skipped: 0
    }
  end
end