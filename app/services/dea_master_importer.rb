# app/services/dea_master_importer.rb
class DeaMasterImporter
  FIELD_MAP = {
    dea_number:            0..10,
    schedules:             11..27,
    expiration_raw:        28..35,
    business_activity:     36..71,
    name:                  72..107,
    address1:              108..143,
    address2:              144..179,
    city:                  180..215,
    state:                 216..217,
    zip:                   218..226,
    status:                227..236,
    state_license_number:  237..270
  }.freeze

  BATCH_SIZE         = 2_000
  PROGRESS_EVERY     = 5_000 # update redis every 5k lines

  def initialize(file_path, job_id)
    @file_path = file_path
    @job_id    = job_id
  end

  def import!
    redis = $redis
    key   = "dea_import:#{@job_id}"

    processed  = 0
    bytes_read = 0
    buffer     = []

    total_bytes = File.size(@file_path)

    redis.pipelined do |r|
      r.hset(key, "processed", 0)
      r.hset(key, "bytes_read", 0)
      r.hset(key, "total_bytes", total_bytes)
      r.hset(key, "last_update", Time.current.to_i)
    end

    File.foreach(@file_path, encoding: "bom|utf-8") do |line|
      processed += 1
      bytes_read += line.bytesize

      line = sanitize(line)
      next if line.strip.empty?

      attrs = extract_attributes(line)
      next if attrs[:dea_number].blank?

      buffer << attrs

      if buffer.size >= BATCH_SIZE
        flush!(buffer)
        buffer.clear
      end

      if (processed % PROGRESS_EVERY).zero?
        redis.pipelined do |r|
          r.hset(key, "processed", processed)
          r.hset(key, "bytes_read", bytes_read)
          r.hset(key, "last_update", Time.current.to_i)
        end
      end
    end

    flush!(buffer) if buffer.any?

    redis.pipelined do |r|
      r.hset(key, "processed", processed)
      r.hset(key, "bytes_read", bytes_read)
      r.hset(key, "last_update", Time.current.to_i)
      r.hset(key, "status", "finished")
    end
  end

  private

  def flush!(rows)
    # IMPORTANT: unique_by must match your unique index name
    DeaMasterRecord.upsert_all(
      rows,
      unique_by: :index_dea_master_records_on_dea_number
    )
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.warn("DEA bulk upsert failed: #{e.message}")
  end

  def sanitize(str)
    str.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
  end

  def safe_slice(line, range)
    return "" unless line && range
    line[range] || ""
  end

  def extract_attributes(line)
    raw_vals = {}

    FIELD_MAP.each do |key, range|
      raw_vals[key] = sanitize(safe_slice(line, range)).strip
    end

    {
      dea_number:           raw_vals[:dea_number],
      schedules:            normalize_schedules(raw_vals[:schedules]),
      expiration_date:      parse_date(raw_vals[:expiration_raw]),
      business_activity:    raw_vals[:business_activity],
      name:                 raw_vals[:name],
      address1:             raw_vals[:address1],
      address2:             raw_vals[:address2],
      city:                 raw_vals[:city],
      state:                raw_vals[:state],
      zip:                  normalize_zip(raw_vals[:zip]),
      status:               raw_vals[:status],
      state_license_number: raw_vals[:state_license_number]
    }
  end

  def normalize_schedules(s)
    s.to_s.split(" ").reject(&:blank?).join(",")
  end

  def parse_date(raw)
    raw = raw.to_s.strip
    return nil unless raw.match?(/\A\d{8}\z/)
    return nil if raw == "00000000" || raw == "99999999" || raw.start_with?("0000")

    mm = raw[4..5].to_i
    dd = raw[6..7].to_i
    return nil if mm < 1 || mm > 12
    return nil if dd < 1 || dd > 31

    Date.strptime(raw, "%Y%m%d")
  rescue Date::Error
    nil
  end

  def normalize_zip(z)
    digits = z.to_s.gsub(/\D/, "")
    digits[0..4]
  end
end
