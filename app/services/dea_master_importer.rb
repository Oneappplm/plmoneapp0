class DeaMasterImporter
  BATCH_SIZE = 2_000
  BYTES_PROGRESS_EVERY = 2 * 1024 * 1024

  # The uploaded DEA file is fixed-width, not comma-separated CSV.
  #
  # Layout based on the supplied DEA file:
  #
  # DEA Number            0..9
  # Spacing              10..12
  # Schedules            13..25
  # Expiration Date      26..33
  # Business Activity    34..69
  # Name                 70..105
  # Address 1           106..141
  # Address 2           142..177
  # City                178..209
  # State               210..211
  # Zip                 212..220
  # Status              221..230
  # State License       231..264
  #
  FIELD_MAP = {
    dea_number: 0..9,
    schedules: 13..25,
    expiration_raw: 26..33,
    business_activity: 34..69,
    name: 70..105,
    address1: 106..141,
    address2: 142..193,
    city: 194..225,
    state: 227..228,
    zip: 229..234,
    status: 236..242,
    state_license_number: 255..263
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

    redis.pipelined do |pipeline|
      pipeline.hset(redis_key, "total_bytes", total_bytes)
      pipeline.hset(redis_key, "status", "running")
      pipeline.hset(redis_key, "processed", 0)
      pipeline.hset(redis_key, "imported", 0)
      pipeline.hset(redis_key, "skipped", 0)
      pipeline.hset(redis_key, "last_update", Time.current.to_i)
    end

    processed = 0
    imported = 0
    skipped = 0
    bytes_read = 0
    next_progress_at = BYTES_PROGRESS_EVERY

    buffer = []
    imported_dea_numbers = []
    current_time = Time.current

    File.open(@file_path, "rb") do |io|
      io.each_line do |raw_line|
        processed += 1
        bytes_read += raw_line.bytesize

        line = sanitize(raw_line).delete_suffix("\n").delete_suffix("\r")

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
        imported_dea_numbers << attributes[:dea_number]
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

    sync_result = sync_provider_deas(imported_dea_numbers)

    redis.pipelined do |pipeline|
      pipeline.hset(redis_key, "processed", processed)
      pipeline.hset(redis_key, "imported", imported)
      pipeline.hset(redis_key, "skipped", skipped)
      pipeline.hset(redis_key, "bytes_read", total_bytes)
      pipeline.hset(redis_key, "total", processed)
      pipeline.hset(
        redis_key,
        "provider_deas_updated",
        sync_result[:updated]
      )
      pipeline.hset(redis_key, "status", "finished")
      pipeline.hset(redis_key, "last_update", Time.current.to_i)
    end

    Rails.logger.info(
      "[DEA IMPORT] Completed " \
      "processed=#{processed} " \
      "imported=#{imported} " \
      "skipped=#{skipped} " \
      "provider_deas_updated=#{sync_result[:updated]}"
    )

    {
      processed: processed,
      imported: imported,
      skipped: skipped,
      provider_deas_updated: sync_result[:updated]
    }
  rescue StandardError => e
    Rails.logger.error(
      "[DEA IMPORT] Failed #{e.class}: #{e.message}"
    )
    Rails.logger.error(e.backtrace.first(30).join("\n"))

    if defined?(redis) && redis.present? && defined?(redis_key)
      redis.pipelined do |pipeline|
        pipeline.hset(redis_key, "status", "failed")
        pipeline.hset(redis_key, "error", "#{e.class}: #{e.message}")
        pipeline.hset(redis_key, "last_update", Time.current.to_i)
      end
    end

    raise
  end

  private

  def validate_file!
    raise ArgumentError, "DEA import file path is missing." if @file_path.blank?

    unless File.exist?(@file_path)
      raise ArgumentError, "DEA import file does not exist: #{@file_path}"
    end

    raise ArgumentError, "DEA import file is empty." if File.zero?(@file_path)
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
    raw_values = FIELD_MAP.each_with_object({}) do |(field, range), values|
      values[field] = field_value(line, range)
    end

    {
      dea_number: normalize_dea_number(raw_values[:dea_number]),
      schedules: normalize_schedules(raw_values[:schedules]),
      expiration_date: parse_date(raw_values[:expiration_raw]),
      business_activity: normalized_text(raw_values[:business_activity]),
      name: normalized_text(raw_values[:name]),
      address1: normalized_text(raw_values[:address1]),
      address2: normalized_text(raw_values[:address2]),
      city: normalized_text(raw_values[:city]),
      state: normalize_state(raw_values[:state]),
      zip: normalize_zip(raw_values[:zip]),
      status: normalized_text(raw_values[:status]),
      state_license_number: normalized_text(
        raw_values[:state_license_number]
      )
    }
  end

  def field_value(line, range)
    sanitize(safe_slice(line, range)).strip
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

  def normalize_dea_number(value)
    value.to_s.upcase.gsub(/[^A-Z0-9]/, "")
  end

  def valid_dea_number?(value)
    normalized = normalize_dea_number(value)

    # Your file examples contain 10-character identifiers such as:
    # A90777889A and AA0077227B.
    normalized.match?(/\A[A-Z0-9]{9,10}\z/)
  end

  def normalize_schedules(value)
    value.to_s
         .upcase
         .scan(/2N|3N|[1-5]/)
         .uniq
         .join(",")
  end

  def normalize_state(value)
    state = value.to_s.upcase.gsub(/[^A-Z]/, "")
    state.match?(/\A[A-Z]{2}\z/) ? state : nil
  end

  def normalize_zip(value)
    digits = value.to_s.gsub(/\D/, "")

    return nil if digits.blank?

    # Preserve ZIP+4 where available.
    digits[0, 9]
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
        estimated_total.positive? ? estimated_total : processed
      )
      pipeline.hset(redis_key, "status", "running")
      pipeline.hset(redis_key, "last_update", Time.current.to_i)
    end
  end

  def sync_provider_deas(imported_dea_numbers)
    return { updated: 0, skipped: 0 } unless defined?(
      DeaMasterProviderSyncService
    )

    DeaMasterProviderSyncService.new(
      dea_numbers: imported_dea_numbers.uniq
    ).call
  rescue StandardError => e
    Rails.logger.error(
      "[DEA IMPORT] ProviderDea sync failed " \
      "#{e.class}: #{e.message}"
    )

    # Do not fail the entire master-file import only because the
    # provider-facing synchronization failed.
    {
      updated: 0,
      skipped: imported_dea_numbers.size,
      error: e.message
    }
  end
end